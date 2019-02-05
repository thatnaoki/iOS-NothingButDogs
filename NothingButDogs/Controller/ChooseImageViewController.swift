//
//  ChooseImageViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ChooseImageViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        //カメラかライブラリかを選択させるAlertController
        //カメラから
        let alertController = UIAlertController(title: "", message: "Camera or Library", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
                
                self.imagePicker.sourceType = .camera
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
                
            })
            
            alertController.addAction(cameraAction)
            
        }
        //ライブラリ
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let photoLibraryAction = UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction) in
                
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.delegate = self
                self.present(self.imagePicker, animated: true, completion: nil)
                
            })
            
            alertController.addAction(photoLibraryAction)
            
        }
        //キャンセル用意
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction) in
            
            self.nextButton.tintColor = UIColor.clear
            
        })
        
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = view
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //画像認識で犬かどうか判定するメソッド
    func detect(image: CIImage) {
        
        //モデルのインスタンス生成
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        //リクエストのインスタンス生成
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //処理実行
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
            //結果の配列でterrierを探す
            for i in 0...20 {
                if results[i].identifier.contains("terrier") {
                    self.navigationItem.title = "It's a Dog!"
                    break
                } else {
                    self.navigationItem.title = "Not a Dog!"
                    self.nextButton.tintColor = UIColor.clear
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    //次の画面へ
    @IBAction func nextPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "goToCreatePost", sender: nil)
        
    }
    

}


extension ChooseImageViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedimage = info[.originalImage] as? UIImage {
            guard let ciimage = CIImage(image: userPickedimage) else {
                fatalError("Could not Convert to CIImage")
            }
            detect(image: ciimage)
            imageView.image = userPickedimage
            print("image is picked!")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! CreatePostViewController
        
        if let choosenImage = imageView.image {
            
            destinationVC.choosenImage = choosenImage
            
        }
        
    }
    
}
