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
        
        if auth.currentUser != nil {
            self.performSegue(withIdentifier: "signinToHome", sender: nil)
        }
        
        signinButton.layer.cornerRadius = 20.0
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    
    @IBAction func signinButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        if emailTextField.text != "" && passwordTextField.text != "" {
           
            auth.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error != nil {
                    print(error!)
                } else {
                    print("Login Successful!")
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "signinToHome", sender: nil)
                }
            }
        } else {
            //2つのどれかがnilだったとき
            print("どっちかnil")
            SVProgressHUD.dismiss()
            self.showAlert(message: "You need to fill everything!")
            return
        }
        
        
        
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "signinToSignup", sender: nil)
        
    }
    
    
    //MARK: キーボード閉じる用
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
        
    }
    

}

