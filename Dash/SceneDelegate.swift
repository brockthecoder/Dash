//
//  SceneDelegate.swift
//  CoreMotionDashboard
//
//  Created by brock davis on 3/26/23.
//

import UIKit

@available(iOS 13, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = DashboardViewController()
        self.window?.makeKeyAndVisible()
    }
}

