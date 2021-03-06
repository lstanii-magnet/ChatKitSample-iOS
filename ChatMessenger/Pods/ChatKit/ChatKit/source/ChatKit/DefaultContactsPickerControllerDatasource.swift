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

import CocoaLumberjack
import MagnetMax

public class DefaultContactsPickerControllerDatasource : NSObject, ContactsControllerDatasource {
    
    
    //MARK: Public Variables
    
    
    public weak var controller : MMXContactsPickerController?
    public var preselectedUsers : [MMUser] = []
    
    
    // Private Variables
    
    
    public var hasMoreUsers : Bool = true
    public let limit = 30
    
    
    //MARK Public Methods
    
    
    public func searchQuery(searchText : String?) -> String {
        var searchQuery = "userName:*"
        if let text = searchText {
            searchQuery = "userName:*\(text)* OR firstName:*\(text)* OR lastName:*\(text)*"
        }
        DDLogInfo("[SearchQuery] - \(searchQuery)")
        
        return searchQuery
    }
    
    
    //MARK: Generic ControllerDatasource
    
    
    public func mmxControllerLoadMore(searchText : String?, offset : Int) {
        
        let searchQuery = self.searchQuery(searchText)
        
        self.hasMoreUsers = offset == 0 ? true : self.hasMoreUsers
        //get request context
        let loadingContext = controller?.loadingContext()
        MMUser.searchUsers(searchQuery, limit: limit, offset: offset, sort: "lastName:asc", success: { users in
            //check if the request is still valid
            if loadingContext != self.controller?.loadingContext() {
                return
            }
            
            if users.count == 0 {
                self.hasMoreUsers = false
                self.controller?.reloadData()
                return
            }
            
            if let picker = self.controller {
                //append users, reload data or insert data
                picker.append(users)
            }
            DDLogVerbose("[Append] -  Users - \(users.count)")
            }, failure: { error in
                DDLogError("[Error] - \(error.localizedDescription)")
                self.controller?.reloadData()
        })
    }
    
    public  func mmxControllerHasMore() -> Bool {
        return self.hasMoreUsers
    }
    
    public func mmxControllerSearchUpdatesContinuously() ->Bool {
        return true
    }
    
    
    //MARK: ContactsPickerControllerDatasource
    
    
    public func mmxContactsControllerPreselectedUsers() -> [MMUser] {
        return preselectedUsers
    }
    
    public func mmxContactsControllerShowsSectionsHeaders() -> Bool {
        return true
    }
    
    public  func mmxContactsControllerShowsSectionIndexTitles() -> Bool {
        return controller?.contacts().count > 1
    }
    
}
