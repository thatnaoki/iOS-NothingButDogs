//
//  SignupViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import SVProgressHUD

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // validation check
        emailTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        
        // button layout
        signupButton.isEnabled = false
        signupButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        signupButton.layer.cornerRadius = 20.0
        
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        //usernameの文字数確認
        if usernameTextField.text!.count <= 10 {
            
            auth.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    print(error!)
                    self.showAlert(message: "Failed to save!")
                    return
                } else {
                    print("Signup Successful!")
                    
                    // get uid
                    guard let uid = auth.currentUser?.uid else {return}
                    
                    // create user document
                    db.collection("users").document(uid).setData([
                        "userName" : self.usernameTextField.text!
                    ])
                }
                SVProgressHUD.dismiss()
                // go to timeline
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.showTimelineStoryboard()
                }
            }
        } else {
            // if name characters are more than 10
            self.showAlert(message: "Names should be in 10 characters or less.")
            return
        }
    }
    
    //MARK: functions
    // close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        usernameTextField.resignFirstResponder()
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
                signupButton.isEnabled = false
                signupButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        // handle case for conditions were met
        signupButton.isEnabled = true
        signupButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    

}
