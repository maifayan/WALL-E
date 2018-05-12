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
        window.rootViewController = LaunchViewController.obtainInstance(finish: me.setupViewControllers)
        window.makeKeyAndVisible()
    }
    
    func _setupGlobalConfig() {
        UIViewController.adaptStatusBarStyle()
        EVE.defaultSetup()
    }
}

extension AppDelegate {
    func setupViewControllers() {
        let setupRootViewController: (UIViewController) -> () = { [weak self] in
            self?.window?.rootViewController = $0
            let transition = CATransition()
            transition.type = kCATransitionFade
            transition.duration = 0.3
            self?.window?.layer.add(transition, forKey: nil)
        }
        
        if let context = Context.createFromPreviousAccount() {
            setupRootViewController(Root.View(context: context))
        } else {
            setupRootViewController(Account.View {
                let context = Context.createAndStoreAccount(token: $0.token, uid: $0.uid)
                setupRootViewController(Root.View(context: context))
            })
        }
    }
}
