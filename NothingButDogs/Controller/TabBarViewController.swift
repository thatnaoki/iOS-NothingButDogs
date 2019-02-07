//
//  TabBarViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/02/07.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //バックボタン隠す
        navigationItem.backBarButtonItem = nil
        navigationItem.hidesBackButton = true

    }
    
    

}
