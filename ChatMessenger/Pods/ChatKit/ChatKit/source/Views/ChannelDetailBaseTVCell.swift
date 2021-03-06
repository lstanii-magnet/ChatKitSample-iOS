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

import MagnetMax

public class ChannelDetailBaseTVCell: UITableViewCell {
    
    
    //MARK: internal properties
    
    
    var detailResponse : MMXChannelDetailResponse? {
        didSet {
            vNewMessageIndicator?.hidden = !hasNewMessagesFromLastTime(useLastMessage : false)
        }
    }
    
    @IBOutlet public weak var vNewMessageIndicator : UIView?

    
    //MARK: Static Methods
    
    
    static func cellHeight() -> CGFloat {
        
        let nibs : [AnyObject]! = NSBundle.mainBundle().loadNibNamed(Utils.name(self.classForCoder()), owner: self, options: nil)
        
        let cellView = nibs.first as! UIView;
        
        return cellView.frame.size.height;
    }
    
    
    //MARK: Overrides
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        if let vNewMessageIndicator = self.vNewMessageIndicator {
            vNewMessageIndicator.layer.cornerRadius = vNewMessageIndicator.bounds.width / 2
            vNewMessageIndicator.clipsToBounds = true
        }
    }

    
    // MARK: - Helpers
    
    
    func hasNewMessagesFromLastTime(useLastMessage useLastMessage: Bool) -> Bool {
        if let detailResponse = self.detailResponse {
            if useLastMessage {
                if let lastMessageID = ChannelManager.sharedInstance.getLastMessageForChannel(detailResponse.channel) {
                    return lastMessageID != detailResponse.messages.last?.messageID
                }
            }
            
            if let lastViewTime = ChannelManager.sharedInstance.getLastViewTimeForChannel(detailResponse.channel) {
                if let sender = detailResponse.messages.last?.sender, let currentUser = MMUser.currentUser() where sender.userID  == currentUser.userID  {
                    return false
                }
                if let lastPublishedTime = detailResponse.lastPublishedTime {
                    
                    return lastViewTime.timeIntervalSince1970 < ChannelManager.sharedInstance.formatter.dateForStringTime(lastPublishedTime)?.timeIntervalSince1970
                    
                }
            }
        }
        
        return true
    }
    
    
}
