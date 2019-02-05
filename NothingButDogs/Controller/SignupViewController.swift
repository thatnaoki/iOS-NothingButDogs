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
        
        signupButton.layer.cornerRadius = 30.0
        
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
                
                let user = Auth.auth().currentUser
                
                if let user = user {
                    self.db.collection("users").document(user.uid).setData([
                        "userName" : self.usernameTextField.text!,
                        "userImageURL" : "https://firebasestorage.googleapis.com/v0/b/nothingbutdogs-e87e5.appspot.com/o/images%2F17004.svg?alt=media&token=17a8ba8c-1ce6-4ab9-9028-64e2a78fe374"])
                    
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
