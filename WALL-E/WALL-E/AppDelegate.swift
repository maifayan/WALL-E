//
//  AppDelegate.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/17.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = Root.View()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}

