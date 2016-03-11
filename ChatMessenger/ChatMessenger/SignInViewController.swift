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

import MagnetMax
import UIKit


class BaseViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    
    //MARK: - public Methods
    
    
    override func showAlert(message :String, title :String, closeTitle :String, handler:((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let button = UIAlertAction(title: closeTitle, style: .Cancel, handler: handler)
        alert.addAction(button)
        self.presentViewController(alert, animated: false, completion: nil)
    }
    
    func hideLoadingIndicator() {
        activityIndicator?.stopAnimating()
        self.view.userInteractionEnabled = true
    }
    
    func showLoadingIndicator() {
        activityIndicator?.startAnimating()
        self.view.userInteractionEnabled = false
    }
    
    
    //MARK: UITextField delegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}

class SignInViewController : BaseViewController {
    
    
    //MARK: Public properties
    
    
    @IBOutlet weak var txtfEmail : UITextField!
    @IBOutlet weak var txtfPassword : UITextField!
    @IBOutlet weak var btnRemember : UISwitch?
    @IBOutlet weak var chbRememberMe: UIImageView?
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resignOnBackgroundTouch()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        txtfPassword.text = ""
        navigationController?.setNavigationBarHidden(true, animated: animated)
        txtfPassword.text = "gogogo"
        txtfEmail.text = "bob@bob.com"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: Actions
    
    
    @IBAction func signInAction() {
        
        // Validate
        if let (email, password) = validateCredential() {
            
            // Login
            self.showLoadingIndicator()
            let credential = NSURLCredential(user: email, password: password, persistence: .None)
            MMUser.login(credential, rememberMe: true, success: {
                self.hideLoadingIndicator()
                let mainVC = self.storyboard?.instantiateViewControllerWithIdentifier(vc_id_SlideMenu)
                self.navigationController?.presentViewController(mainVC!, animated: true, completion: nil)
                }, failure: { error in
                    print("[ERROR]: \(error)")
                    self.hideLoadingIndicator()
                    
                    self.showAlert("Please check username and password and try again", title: "Could not log in", closeTitle: "ok")
                    
            })
        } else {
            self.showAlert("Please Fill the required fields", title: "Required", closeTitle: "ok")
        }
    }
    
    
    //MARK: - private Methods
    
    
    private func validateCredential() -> (String, String)? {
        
        guard let email = txtfEmail.text where (email.isEmpty == false) else {
            return nil
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false) else {
            return nil
        }
        
        return (email, password)
    }
}
