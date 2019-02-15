//
//  Extension.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/02/06.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit

extension UIViewController {

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func showAlert(message: String) {
        
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            alert.dismiss(animated: true, completion: nil)
            
        }))
        
        self.present(alert, animated: true)
        
    }
    
}

extension UIImageView {
    
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    func cacheImage(imageUrlString: String) {
        
        let url = URL(string: imageUrlString)
        
        if let imageFromCache = UIImageView.imageCache.object(forKey: imageUrlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        self.image = UIImage(named: "placeholder")
        
        URLSession.shared.dataTask(with: url!) { (data, urlResponse, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                let imageToCache = UIImage(data:data!)
                
                self.image = imageToCache
                
                UIImageView.imageCache.setObject(imageToCache!, forKey: imageUrlString as AnyObject)
            }
        }.resume()
    }
}
