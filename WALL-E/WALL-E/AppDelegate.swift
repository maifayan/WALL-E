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
        _setupGlobalConfig()
        _setupWindow()
        return true
    }
}

private extension AppDelegate {
    func _setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
        window.rootViewController = LaunchViewController.obtainInstance { [weak self] in
            self?._setupRootViewController()
        }
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func _setupRootViewController() {
        window?.rootViewController = Root.View()
        let transition = CATransition()
        transition.type = kCATransitionFade
        transition.duration = 0.3
        window?.layer.add(transition, forKey: nil)
    }
    
    func _setupGlobalConfig() {
        UIViewController.adaptStatusBarStyle()
    }
}

