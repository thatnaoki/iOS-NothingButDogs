//
//  ViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import SVProgressHUD

class SigninViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // auto signin
        if auth.currentUser != nil {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showTimelineStoryboard()
            }
        }
        
        // validation check
        emailTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        // button layout
        signinButton.isEnabled = false
        signinButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        signinButton.layer.cornerRadius = 20.0
        
        // set delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    // MARK: button action
    @IBAction func signinButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        auth.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error!)
                self.showAlert(message: "failed to login!")
                return
            } else {
                print("Login Successful!")
                SVProgressHUD.dismiss()
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.showTimelineStoryboard()
                }
            }
        }
    }
    
    // if no account
    @IBAction func signupButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "signinToSignup", sender: nil)
    }
    
    
    // MARK: functions
    // close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
        
    }
    
    // validation check
    @objc func formValidation() {
        
        guard
            emailTextField.hasText,
            passwordTextField.hasText else {
                // handle case for above conditions not met
                signinButton.isEnabled = false
                signinButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        // handle case for conditions were met
        signinButton.isEnabled = true
        signinButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    

}

