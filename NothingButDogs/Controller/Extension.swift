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
    
}
