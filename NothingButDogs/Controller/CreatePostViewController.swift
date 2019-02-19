//
//  CreaetPostViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class CreatePostViewController: UIViewController, UITextFieldDelegate {

    var choosenImage: UIImage?
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("is this PostTableViewController? -> \(String(describing: self.presentingViewController?.presentingViewController))")

        shareButton.layer.cornerRadius = 20.0
        
        guard let choosenImage = choosenImage else {
            fatalError("image is not choosen")
        }
        postImage.image = self.cropRect(image: choosenImage)
    }
    
    // MARK: functions
    // save data to storage
    func setDataToStorage(_ image: UIImage, completion: @escaping (String?, Error?)->Void) {
        
        if let imageData = postImage.image!.jpegData(compressionQuality: 0.8) {
            // create file name
            let imageName = NSUUID().uuidString
            
            // save to storage
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
    
    // MARK: button actions
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        // save to database
        setDataToStorage(postImage.image!) {urlString, _ in
            //Dateの用意
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            let now = Date()
            //ログイン中のユーザー取得
            let user = auth.currentUser
            
            if let user = user {
                
                db.collection("posts").document().setData([
                    "userId" : user.uid,
                    "postImageURL" : urlString!,
                    "numberOfLike" : 0,
                    "createdAt" : f.string(from: now),
                    "timestamp": FieldValue.serverTimestamp()
                    ])
            }
    
            SVProgressHUD.dismiss()
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[0])!, animated: true)
        }
    }
}

extension CreatePostViewController {
    
    // crop a photo
    private func cropRect(image: UIImage) -> UIImage {
        
        // argument
        var image = image
        
        // make sure a photo looks correct
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        if let _image = UIGraphicsGetImageFromCurrentImageContext() {
            image = _image
        }
        UIGraphicsEndImageContext()
        
        // cropping
        if image.size.width != image.size.height {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w = image.size.width
            var h = image.size.height
            if w > h {
                // if a photo is landscape
                x = (w - h) / 2
                w = h
            } else {
                // if a photo is portrait
                y = (h - w) / 2
                h = w
            }
            let cgImage = image.cgImage?.cropping(to: CGRect(x: x, y: y, width: w, height: h))
            image = UIImage(cgImage: cgImage!)
        }
        
        // make photo small
        let newSize = CGSize(width: 720, height: 720)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        if let _image = UIGraphicsGetImageFromCurrentImageContext() {
            image = _image
        }
        UIGraphicsEndImageContext()
        
        // return
        return image
    }
}
