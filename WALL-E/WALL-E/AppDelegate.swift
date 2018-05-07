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
    
    // Just for test
    private var _connecter: EVE.Connecter!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _setupGlobalConfig()
        _setupWindow()
        
        
//        // Just for test
//        _connecter = EVE.Connecter()
//        _connecter.connect()
//        let context = Context(token: "", uid: "")
//        do {
//            let auto = try Auto(context)
//            print(auto)
//            print("ok")
//        } catch {
//            print(error)
//        }
        return true
    }
}

private extension AppDelegate {
    func _setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
        _setupRootViewController()
//        window.rootViewController = LaunchViewController.obtainInstance { [weak self] in
//            self?._setupRootViewController()
//        }
        window.rootViewController = Account.View()
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

