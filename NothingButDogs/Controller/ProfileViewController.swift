//
//  ProfileViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/02/06.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    let docRef = db.collection("users").document((auth.currentUser?.uid)!)
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateButton.layer.cornerRadius = 20.0
        userNameTextField.delegate = self
        
        
        docRef.getDocument() { (document, error) in
            
            if let document = document, document.exists {
                
                let data = document.data()!
                
                let userName = data["userName"] as? String
                
                self.userNameTextField.text = userName!
                
            }
        }
    }
    
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        if let newUserName = userNameTextField.text {
            
            docRef.updateData([
                "userName" : newUserName
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
    
    //MARK: キーボード閉じる用
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        userNameTextField.resignFirstResponder()
        return true
        
    }
    
    
}
