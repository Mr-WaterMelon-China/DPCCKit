//
//  AppDelegate.swift
//  DPCCKit
//
//  Created by liwang on 04/26/2023.
//  Copyright (c) 2023 liwang. All rights reserved.
//

import UIKit
import DPCCKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        windowSet()
        DPCCKitManager.auth(appKey: "43020eb69b25e193fa2116986b7b477b", bundleId: "com.dpcc.dpccvue.DPCCDemo")
        return true
    }

    //MARK: - 设置window
    fileprivate func windowSet() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        let nav = UINavigationController.init(rootViewController: TestViewController())
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }

}

