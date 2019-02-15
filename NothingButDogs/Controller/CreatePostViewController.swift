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
    @IBOutlet weak var postTextField: UITextField!
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
    
    func setDataToStorage(_ image: UIImage, completion: @escaping (String?, Error?)->Void) {
        
        if let imageData = postImage.image!.jpegData(compressionQuality: 0.8) {
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
    
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        
        SVProgressHUD.show()
        let group = DispatchGroup()
        setDataToStorage(postImage.image!) {urlString, _ in
            group.enter()
            //データベースへの保存
            //Dateの用意
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .medium
            let now = Date()
            //ログイン中のユーザー取得
            let user = auth.currentUser
            
            if let user = user {
                
                db.collection("posts").document().setData([
                    "userId" : user.uid,
                    "postImageURL" : urlString!,
                    "postText" : self.postTextField.text!,
                    "numberOfLike" : 0,
                    "createdAt" : f.string(from: now),
                    "timestamp": FieldValue.serverTimestamp()
                    ])
            
            }
            
            group.leave()
        
        }
        group.notify(queue: .main) {
        
            SVProgressHUD.dismiss()
            print("presentingViewController -> \(self.presentingViewController?.presentingViewController)")
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }

    }

}

//MARK: キーボード閉じる系
extension CreatePostViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        postTextField.resignFirstResponder()
        return true
        
    }
    
}

extension CreatePostViewController {
    
    // 画像を正方形にクロップする.
    private func cropRect(image: UIImage) -> UIImage {
        
        // 加工対象の画像.
        var image = image
        
        // 天地が反転している場合があるので、対応しておく.
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        if let _image = UIGraphicsGetImageFromCurrentImageContext() {
            image = _image
        }
        UIGraphicsEndImageContext()
        
        // 正方形にクロップする.
        if image.size.width != image.size.height {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var w = image.size.width
            var h = image.size.height
            if w > h {
                // 横長の場合.
                x = (w - h) / 2
                w = h
            } else {
                // 縦長の場合.
                y = (h - w) / 2
                h = w
            }
            let cgImage = image.cgImage?.cropping(to: CGRect(x: x, y: y, width: w, height: h))
            image = UIImage(cgImage: cgImage!)
        }
        
        // サイズが大きすぎても困るので、小さくしておく.
        let newSize = CGSize(width: 720, height: 720)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        if let _image = UIGraphicsGetImageFromCurrentImageContext() {
            image = _image
        }
        UIGraphicsEndImageContext()
        
        // 返却する.
        return image
    }
}
