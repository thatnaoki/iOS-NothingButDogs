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
