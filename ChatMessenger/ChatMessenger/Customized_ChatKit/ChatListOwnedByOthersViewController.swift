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


//MARK: Class for chat list owned by others


class ChatListOwnedByOthersViewController: MMXChatListViewController {
    
    override func setupViewController() {
        
        super.setupViewController()
        
        //datasource for chats owned by others
        
        let customDatasource = ChatListOwnedByOthersDatasource()
        customDatasource.controller = self
        self.datasource = customDatasource
        self.title = "Chats Owned by Others"
        self.chooseContacts = false
    }
}