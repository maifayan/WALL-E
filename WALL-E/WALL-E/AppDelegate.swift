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
        unowned let me = self
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
        window.rootViewController = LaunchViewController.obtainInstance(finish: me._setupControllers)
        window.makeKeyAndVisible()
    }
    
    func _setupControllers() {
        let setupRootViewController: (UIViewController) -> () = { [weak self] in
            self?.window?.rootViewController = $0
            let transition = CATransition()
            transition.type = kCATransitionFade
            transition.duration = 0.3
            self?.window?.layer.add(transition, forKey: nil)
        }
        
        let showRootView: (Account.AccountInfo) -> () = {
            let context = Context(token: $0.token, uid: $0.uid)
            setupRootViewController(Root.View(context: context))
        }

        if let accountInfo = Account.accountInfo {
            showRootView(accountInfo)
        } else {
            setupRootViewController(Account.View {
                Account.accountInfo = $0
                showRootView($0)
            })
        }
    }
    
    func _setupGlobalConfig() {
        UIViewController.adaptStatusBarStyle()
        EVE.defaultSetup()
    }
}

