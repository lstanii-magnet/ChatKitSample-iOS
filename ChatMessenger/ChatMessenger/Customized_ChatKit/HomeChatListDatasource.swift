/*
* Copyright (c) 2016 Magnet Systems, Inc.
* All rights reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License"); you
* may not use this file except in compliance with the License. You
* may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
* implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

import UIKit
import ChatKit


//MARK: datasource for first screen


class HomeChatListDatasource : DefaultChatListControllerDatasource {
    
    
    //MARK: Internal Variables
    
    
    var loadingGroup : dispatch_group_t = dispatch_group_create()
    
    
    //MARK: custom overrides
    
    
    func mmxListDidCreateCell(cell: UITableViewCell) {
        if let listCell = cell as? ChatListCell {
            listCell.lblMessage?.textColor = UIColor.purpleColor()
            listCell.lblSubscribers?.textColor = UIColor(red: 68/255.0, green: 235/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    func mmxListSortChannelDetails(channelDetails: [MMXChannelDetailResponse]) -> [MMXChannelDetailResponse] {
        
        let details = channelDetails.sort({ (detail1, detail2) -> Bool in
            let formatter = ChannelManager.sharedInstance.formatter
            return formatter.dateForStringTime(detail1.lastPublishedTime)?.timeIntervalSince1970 > formatter.dateForStringTime(detail2.lastPublishedTime)?.timeIntervalSince1970
        })
        
        let eventChannels = details.filter({$0.channelName.hasPrefix("global_")})
        let otherChannels = details.filter({!$0.channelName.hasPrefix("global_")})
        
        var results : [MMXChannelDetailResponse] = []
        
        if eventChannels.count > 0 {
            results.appendContentsOf(eventChannels)
        }
        
        if otherChannels.count > 0 {
            results.appendContentsOf(otherChannels)
        }
        
        return results
    }
    
    override func mmxListRegisterCells(tableView: UITableView) {
        let nib = UINib.init(nibName: "EventsTableViewCell", bundle: NSBundle(forClass: HomeChatListDatasource.self))
        tableView.registerNib(nib, forCellReuseIdentifier: "EventsTableViewCell")
    }
    
    func mmxListCellHeightForChannel(channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath: NSIndexPath) -> CGFloat {
        if channelDetails.channelName.hasPrefix("global_") {
            return 170.0
        }
        return 80.0
    }
    
    func mmxListCellForChannel(tableView: UITableView, channel: MMXChannel, channelDetails: MMXChannelDetailResponse, indexPath: NSIndexPath) -> UITableViewCell? {
        if channelDetails.channelName.hasPrefix("global_") {
            if let cell = tableView.dequeueReusableCellWithIdentifier("EventsTableViewCell", forIndexPath: indexPath) as? EventsTableViewCell {
                if channelDetails.channelName.hasPrefix("global_AWESOME_EVENT") {
                    cell.eventImage?.image = UIImage(named: "bg_img_1_2.png")
                    cell.eventLabel?.text = ""
                } else {
                    cell.eventImage?.image = nil
                    cell.eventImage?.backgroundColor = UIColor(red: 48/255.0, green: 195/255.0, blue: 114/255.0, alpha: 1.0)
                    cell.eventLabel?.text = channelDetails.channel.summary
                    cell.eventLabel?.textColor = UIColor.whiteColor()
                }
                return cell
            }
        }
        return nil
    }
    
    func loadEventChannels() {
        MMXChannel.findByTags( Set(["active"]), limit: 5, offset: 0, success: { [weak self] total, channels in
            if channels.count > 0 {
                let serviceGroup : dispatch_group_t = dispatch_group_create()
                let lock = NSLock()
                var events : [MMXChannel] = []
                
                for  channel in channels {
                    dispatch_group_enter(serviceGroup)
                    
                    channel.subscribeWithSuccess({
                        
                        lock.lock()
                        events.append(channel)
                        lock.unlock()
                        
                        dispatch_group_leave(serviceGroup)
                        }, failure: { (error) -> Void in
                            print("subscribe global error \(error)")
                            dispatch_group_leave(serviceGroup)
                    })
                }
                
                dispatch_group_notify(serviceGroup, dispatch_get_main_queue(),{
                    self?.controller?.append(events)
                })
            }
            }) { (error) -> Void in
        }
    }
    
    override func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        dispatch_group_enter(loadingGroup)
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            let cV = ch.filter({ return $0.ownerUserID == MMUser.currentUser()!.userID && !$0.name.hasPrefix("global_") })
            completion(channels: cV)
            dispatch_group_leave(self.loadingGroup)
            }) { error in
                print(error)
                completion(channels: [])
                dispatch_group_leave(self.loadingGroup)
        }
    }
    
    func mmxListShouldAppendNewChannel(channel: MMXChannel) -> Bool {
        return channel.ownerUserID == MMUser.currentUser()?.userID
    }
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
        super.mmxControllerLoadMore(searchText, offset: offset)
        
        if offset == 0 {
            dispatch_group_notify(loadingGroup, dispatch_get_main_queue(),{
                self.loadEventChannels()
            })
        }
    }
}
