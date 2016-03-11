//
//  ViewController.swift
//  UBank
//
//  Created by Lorenzo Stanton on 3/3/16.
//  Copyright © 2016 Lorenzo Stanton. All rights reserved.
//

import UIKit
import ChatKit

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
    
}

