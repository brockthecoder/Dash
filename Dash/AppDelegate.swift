//
//  AppDelegate.swift
//  CoreMotionDashboard
//
//  Created by brock davis on 3/26/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #unavailable(iOS 13) {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = DashboardViewController()
            window.makeKeyAndVisible()
            self.window = window
        }
        return true
    }

    @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}

