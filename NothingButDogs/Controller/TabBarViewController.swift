//
//  TabbarViewController.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/02/08.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
    }
    
    

}
