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


//MARK: custom chat view


public class MyChatViewController : MMXChatViewController {
    
    override public var currentDetailsViewController : MMXContactsPickerController? {
        didSet {
            currentDetailsViewController?.tableView.backgroundColor = UIColor.orangeColor()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.yellowColor()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.title?.characters.count == 0 {
            self.title = "--"
        }
        
        if let name = self.channel?.name {
            if name.hasPrefix("global_") {
                self.title = self.channel?.summary?.capitalizedString
            }
        }
    }
}


//MARK: datasource for first screen


class CustomListDatasource : DefaultChatListControllerDatasource {
    
    var eventChannels : [MMXChannel] = []
    
    
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
        let nib = UINib.init(nibName: "EventsTableViewCell", bundle: NSBundle(forClass: CustomListDatasource.self))
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
                } else {
                    cell.eventImage?.image = UIImage(named: "event.png")
                }
                return cell
            }
        }
        return nil
    }
    
    func loadEventChannels() {
        // let context = self.controller?.loadingContext()
        MMXChannel.findByTags( Set(["active"]), limit: 5, offset: 0, success: { [weak self] total, channels in
            if channels.count > 0 {
                let channel = channels.first
                channel?.subscribeWithSuccess({
                    MMXChannel.channelDetails(channels, numberOfMessages: 1, numberOfSubcribers: 3, success: { (responseDetails) -> Void in
                        if self?.eventChannels.count == 0 {
                            self?.eventChannels = channels
                            self?.controller?.append(channels)
                        }
                        }, failure: { (error) -> Void in
                            
                    })
                    }, failure: { (error) -> Void in
                        print("subscribe global error \(error)")
                })
            }
            }) { (error) -> Void in
        }
    }
    
    override func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            let cV = ch.filter({ return $0.ownerUserID == MMUser.currentUser()!.userID})
            completion(channels: cV)
            }) { error in
                print(error)
                completion(channels: [])
        }
    }
    
    override func mmxControllerLoadMore(searchText: String?, offset: Int) {
        super.mmxControllerLoadMore(searchText, offset: offset)
        if offset == 0 {
            self.eventChannels = []
        }
        loadEventChannels()
    }
}


//MARK: datasource for chats owned by others


class CustomList2Datasource : DefaultChatListControllerDatasource {
    
    override func subscribedChannels(completion : ((channels : [MMXChannel]) -> Void)) {
        MMXChannel.subscribedChannelsWithSuccess({ ch in
            let cV = ch.filter({ return $0.ownerUserID != MMUser.currentUser()!.userID && !$0.name.hasPrefix("global_")})
            completion(channels: cV)
            }) { error in
                print(error)
                completion(channels: [])
        }
    }
}


//MARK: Class for chat list owned by others


class ChatListOwnedByOthers: MMXChatListViewController {
    
    override func setupViewController() {
        super.setupViewController()
        
        //datasource for chats owned by others
        
        let customDatasource = CustomList2Datasource()
        customDatasource.controller = self
        self.datasource = customDatasource
    }
}


//MARK:  Custom chat list Delegate


class CustomChatListDelegate : DefaultChatListControllerDelegate {
    override func mmxListCanLeaveChannel(channel: MMXChannel, channelDetails: MMXChannelDetailResponse) -> Bool {
        if channel.name.hasPrefix("global_") {
            return false
        }
        
        return super.mmxListCanLeaveChannel(channel, channelDetails: channelDetails)
    }
}


//MARK: custom chat list controller


class ViewController: MMXChatListViewController {
    
    @IBOutlet var menuButton : UIButton?
    private var revealLoaded : Bool = false
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !revealLoaded {
            revealLoaded = true
            if self.revealViewController() != nil {
                menuButton?.addTarget(self.revealViewController(), action: "revealToggle:", forControlEvents: .TouchUpInside)
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
    }
    var _chatViewController : MMXChatViewController?
    
    
    //Override default chatview with a custom one
    
    
    override weak var currentChatViewController : MMXChatViewController? {
        set {
            var controller : MMXChatViewController?
            if let channel = newValue?.channel {
                controller = MyChatViewController(channel: channel)
            } else if let users = newValue?.recipients {
                controller = MyChatViewController(recipients: users)
            }
            _chatViewController = controller
            _chatViewController?.title = newValue?.title
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        }
        get {
            return _chatViewController
        }
    }
    
    
    override func setupViewController() {
        super.setupViewController()
        
        //added custom datasource for chats current user owns
        let customDatasource = CustomListDatasource()
        customDatasource.controller = self
        self.datasource = customDatasource
        
        let customDelegate = CustomChatListDelegate()
        customDelegate.controller = self
        self.delegate = customDelegate
        
        self.registerCells(self.tableView)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.cellBackgroundColor = UIColor(red: 255.0/255.0, green: 243.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        self.tableView.backgroundColor = self.cellBackgroundColor
    }
    
    @IBAction func btnPressed() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.title, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        let chatListViewController = ChatListOwnedByOthers()
        chatListViewController.title = "Chats Owned by Others"
        chatListViewController.chooseContacts = false
        self.navigationController?.pushViewController(chatListViewController, animated: true)
    }
}







