//
//  ProfileViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/02/06.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    // reference to document
    let docRef = db.collection("users").document((auth.currentUser?.uid)!)
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // button layout
        updateButton.layer.cornerRadius = 20.0
        
        // set delegate
        userNameTextField.delegate = self
        
        // get data from firestore
        docRef.getDocument() { (document, error) in
            
            if let document = document, document.exists {
                
                let data = document.data()!
                
                let userName = data["userName"] as? String
                
                self.userNameTextField.text = userName!
                
            }
        }
    }
    
    // MARK: button actions
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        if userNameTextField.text != "" {
            
            if userNameTextField.text!.count <= 10 {
                
                docRef.updateData([
                    "userName" : userNameTextField.text!
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        self.showAlert(message: "Successfully updated!")
                    }
                }
                
            } else {
                showAlert(message: "Names should be in 10 characters or less.")
                return
            }
        } else {
            showAlert(message: "You must put something!")
        }
    }
    
    // signout
    @IBAction func signoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try auth.signOut()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.showWelcomeStroyboard()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        userNameTextField.resignFirstResponder()
        return true
        
    }
    
    
}
