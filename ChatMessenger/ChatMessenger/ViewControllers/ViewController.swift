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


//MARK: custom chat list controller


class ViewController: MMXChatListViewController {
    
    
    //MARK: Internal Variables
    
    
    var _chatViewController : MMXChatViewController?
    @IBOutlet var menuButton : UIButton?
    
    
    //MARK: Private Variables
    
    
    private var revealLoaded : Bool = false
    
    
    //MARK: Overrides
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !revealLoaded {
            revealLoaded = true
            if self.revealViewController() != nil {
                menuButton?.addTarget(self.revealViewController(), action: #selector(self.revealViewController().revealToggle(_:)), forControlEvents: .TouchUpInside)
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
    }
    
    
    //Override default chatview with a custom one
    
    
    override weak var currentChatViewController : MMXChatViewController? {
        set {
            var controller : MMXChatViewController?
            if let channel = newValue?.channel {
                controller = CustomChatViewController(channel: channel)
            } else if let users = newValue?.recipients {
                controller = CustomChatViewController(recipients: users)
            }
            _chatViewController = controller
            _chatViewController?.title = newValue?.title
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            if let name = _chatViewController?.channel?.name where name.hasPrefix("global_") {
                _chatViewController?.collectionView?.backgroundColor = UIColor.purpleColor()
                _chatViewController?.outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
            }
        }
        get {
            return _chatViewController
        }
    }
    
    var customDatasource : ChatListControllerDatasource {
        get {
            let customDatasource = HomeChatListDatasource()
            customDatasource.controller = self
            return customDatasource
        }
    }
    
    override var datasource: ChatListControllerDatasource? {
        set { }
        
        get {
            return customDatasource
        }
    }
    
    override func viewDidLoad() {
        
        //added custom datasource for chats current user owns
        
        
        let customDelegate = CustomChatListDelegate()
        customDelegate.controller = self
        self.delegate = customDelegate
        
        super.viewDidLoad()
        
        self.cellBackgroundColor = UIColor(red: 255.0/255.0, green: 243.0/255.0, blue: 233.0/255.0, alpha: 1.0)
        self.tableView.backgroundColor = self.cellBackgroundColor
    }
}
