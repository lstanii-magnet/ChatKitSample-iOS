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

import AFNetworking
import MagnetMax
import UIKit

class RegisterViewController : BaseViewController {
    
    
    //MARK: Public properties
    
    var keyboardIsShowing = false
    @IBOutlet weak var txtfFirstName : UITextField!
    @IBOutlet weak var txtfLastName : UITextField!
    @IBOutlet weak var txtfEmail : UITextField!
    @IBOutlet weak var txtfPassword : UITextField!
    @IBOutlet weak var txtfPasswordAgain : UITextField!
    var viewOffset: CGFloat!
    
    
    //MARK: Overrides
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resignOnBackgroundTouch()
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueRegisterToHome {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: kUserDefaultsShowProfile)
        }
    }
    
    
    //MARK: Public Methods
    
    
    func login(credential: NSURLCredential) {
        
        MMUser.login(credential, rememberMe: true, success: { [weak self] in
            self?.hideLoadingIndicator()
            let mainVC = self?.storyboard?.instantiateViewControllerWithIdentifier(vc_id_SlideMenu)
             self?.navigationController?.presentViewController(mainVC!, animated: true, completion: nil)
            }, failure: { [weak self] error  in
                self?.hideLoadingIndicator()
                print("[ERROR]: \(error.localizedDescription)")
                self?.navigationController?.popToRootViewControllerAnimated(true)
            })
    }
    
    
    //MARK: Actions
    
    
    @IBAction func registerAction() {
        
        do {
            // Validate
            let (firstName, lastName, email, password) = try validateCredential()
            
            // Register
            let user = MMUser()
            user.userName = email
            user.firstName = trimWhiteSpace(firstName)
            user.lastName = trimWhiteSpace(lastName)
            user.password = password
            user.email = trimWhiteSpace(email)
            
            // Login
            let credential = NSURLCredential(user: email, password: password, persistence: .None)
            
            self.showLoadingIndicator()
            
            user.register({ [weak self] user in
                self?.login(credential)
                }, failure: { [weak self] error in
                    
                    self?.hideLoadingIndicator()
                    print("[ERROR]: \(error)")
                    
                    if MMXHttpError(rawValue: error.code) == .Conflict {
                        self?.showAlert(kStr_UsernameTaken, title: kStr_UsernameTitle, closeTitle: kStr_Close)
                    } else if MMXHttpError(rawValue: error.code) == .ServerTimeout || MMXHttpError(rawValue: error.code) == .Offline {
                        self?.showAlert(kStr_NoInternetError, title: kStr_NoInternetErrorTitle, closeTitle: kStr_Close)
                    } else {
                        self?.showAlert(kStr_PleaseTryAgain, title:kStr_CouldntRegisterTitle, closeTitle: kStr_Close)
                    }
                })
        } catch InputError.InvalidUserNames {
            self.showAlert(kStr_EnterFirstLastName, title: kStr_FieldRequired, closeTitle: kStr_Close)
        } catch InputError.InvalidEmail {
            self.showAlert(kStr_EnterEmail, title: kStr_FieldRequired, closeTitle: kStr_Close)
        } catch InputError.InvalidPassword {
            self.showAlert(kStr_EnterPasswordAndVerify, title: kStr_FieldRequired, closeTitle: kStr_Close)
        } catch InputError.InvalidPasswordLength {
            self.showAlert(kStr_EnterPasswordLength, title: kStr_PasswordShort, closeTitle: kStr_Close)
        } catch { }
    }
    
    
    // MARK: Private implementation
    
    
    private enum InputError: ErrorType {
        case InvalidUserNames
        case InvalidEmail
        case InvalidPassword
        case InvalidPasswordLength
    }
    
    private func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func trimWhiteSpace(string : String) -> String {
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    private func validateCredential() throws -> (String, String, String, String) {
        // Get values from UI
        guard let firstName = txtfFirstName.text where (trimWhiteSpace(firstName).characters.count >= kMinNameLength),
            let lastName = txtfLastName.text where (trimWhiteSpace(lastName).characters.count >= kMinNameLength) else {
                throw InputError.InvalidUserNames
        }
        
        guard let email = txtfEmail.text where (email.isEmpty == false) && isValidEmail(trimWhiteSpace(email)) else {
            throw InputError.InvalidEmail
        }
        
        guard let password = txtfPassword.text where (password.isEmpty == false),
            let passwordAgain = txtfPasswordAgain.text where (passwordAgain.isEmpty == false && password == passwordAgain) else {
                throw InputError.InvalidPassword
        }
        
        if password.characters.count < kMinPasswordLength { throw InputError.InvalidPasswordLength }
        
        return (firstName, lastName, email, password)
    }
}
