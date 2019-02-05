//
//  SignupViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class SignupViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupButton.layer.cornerRadius = 20.0
        
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        //TODO: Set up a new user on our Firbase database
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("Signup Successful!")
                //userdefaultにuser情報保存
                let userDefault = UserDefaults.standard
                userDefault.register(defaults: ["id" : self.emailTextField.text!])
                userDefault.register(defaults: ["password" : self.passwordTextField.text!])
                
                //Firebaseでuser document作成
                let user = Auth.auth().currentUser
                
                if let user = user {
                    self.db.collection("users").document(user.uid).setData([
                        "userName" : self.usernameTextField.text!
                    ])
                }
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "signupToHome", sender: self)
            }
        }
    }
    
    //MARK: キーボード閉じる用
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
        
    }
    

}