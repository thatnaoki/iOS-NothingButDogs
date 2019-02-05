//
//  CreaetPostViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import Firebase

class CreatePostViewController: UIViewController, UITextFieldDelegate {

    var choosenImage: UIImage?
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton.layer.cornerRadius = 20.0
        
        guard let choosenImage = choosenImage else {
            fatalError("image is not choosen")
        }
        postImage.image = choosenImage
    }
    
    func setDataToStorage(_ image: UIImage, completion: @escaping (String?, Error?)->Void) {
        
        if let imageData = postImage.image!.pngData() {
            //ファイル名生成
            let imageName = NSUUID().uuidString
            
            //Storageへの保存
            let reference = storage.reference().child("images/" + imageName + ".jpg")
            reference.putData(imageData, metadata: nil, completion: { metaData, error in
                
                if error != nil {
                    completion(nil, error)
                }
                
                reference.downloadURL{ url, error in
                    
                    guard let downloadURL = url else {
                        print("failed to get the download url")
                        return
                    }
                    
                    let urlString = downloadURL.absoluteString
                    
                    completion(urlString, nil)
                }
            })
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
        setDataToStorage(postImage.image!) {urlString, _ in
            //データベースへの保存
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .medium
            let now = Date()
            //ログイン中のユーザー取得
            let user = Auth.auth().currentUser
            
            if let user = user {
                
                self.db.collection("posts").document().setData([
                    "userId" : user.uid,
                    "postImageURL" : urlString!,
                    "postText" : self.postTextField.text!,
                    "numberOfLike" : 0,
                    "createdAt" : f.string(from: now)
                    ])
            }
        }
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}


//MARK: キーボード閉じる系
extension CreatePostViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        postTextField.resignFirstResponder()
        return true
        
    }
    
}
