//
//  AppDelegate.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }

    func showTimelineStoryboard() {
        let vc = UIStoryboard(name: "AfterLogin", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func showWelcomeStroyboard() {
        let vc = UIStoryboard(name: "BeforeLogin", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = vc
        
    }

}

