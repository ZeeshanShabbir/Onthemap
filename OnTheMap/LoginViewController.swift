//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/3/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        showUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if(Reachability.connectedToNetwork()){
        hideUI()
        showActivityIndicator()
        APIClient.shareInstance.createSession(username: emailTextField.text!, password: passwordTextField.text!){ sucess, result, error in
            if sucess {
                performUIUpdatesOnMain {
                    print("login was successful")
                    self.hideActivityIndicator()
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "tabcontroller")
                    self.present(viewController!, animated: true, completion: nil)
                }
            }else{
                performUIUpdatesOnMain {
                    print("login was failed")
                    self.hideActivityIndicator()
                    self.showUI()
                    self.showAlert(title: "Login Failed", message: "Wrong email and password, Try Again")
                }
            }
        }
        } else{
            performUIUpdatesOnMain {
                self.showAlert(title: "No Internet Connection", message: "You don't seem to have internet Connection available")
            }
        }
    }
        
}

fileprivate protocol SetUiProtocol{
    func configureUI()
    func showUI()
    func hideUI()
}

fileprivate protocol KeyboardProtocol{
    func subscribeKeyboardNotifications()
    func keyboardWillShow(_ notification: NSNotification)
    func keyboardWillHide(_ notification: NSNotification)
    func getKeyboardHeight(notification: NSNotification) -> CGFloat
    func unsubscribeFromKeyboardNotifications()
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text?.isEmpty)!{
            if textField == emailTextField{
                textField.placeholder = APIClient.Placeholders.email
            } else if textField == passwordTextField{
                textField.placeholder = APIClient.Placeholders.password
            }
        }
    }
    
}

extension LoginViewController: SetUiProtocol{
    internal func hideUI() {
        passwordTextField.isHidden = true
        emailTextField.isHidden = true
        loginButton.isHidden = true
        
    }

    internal func showUI() {
        passwordTextField.isHidden = false
        emailTextField.isHidden = false
        loginButton.isHidden = false
    }

    internal func configureUI() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
}


extension LoginViewController: KeyboardProtocol{
    
    internal func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    internal func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    internal func keyboardWillHide(_ notification: NSNotification) {
        if passwordTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }

    internal func keyboardWillShow(_ notification: NSNotification) {
        if passwordTextField.isFirstResponder {
            view.frame.origin.y =  getKeyboardHeight(notification: notification) * -1
        }
    }

    internal func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
}

