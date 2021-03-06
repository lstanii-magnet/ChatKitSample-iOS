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

class CustomChatViewController: MMXChatViewController {
    
    
    //MARK: Internal Overrides
    
    
    override internal var chatDetailsViewController : MMXContactsPickerController? {
        didSet {
            chatDetailsViewController?.tableView.backgroundColor = UIColor.orangeColor()
        }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.backgroundColor = UIColor.yellowColor()
    }
    
    internal override func viewWillAppear(animated: Bool) {
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
