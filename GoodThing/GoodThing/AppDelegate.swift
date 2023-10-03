//
//  AppDelegate.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/14.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore



@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var animationWindow: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.showAnimation()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainTabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            self.window?.rootViewController = mainTabBarController
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    func showAnimation() {
        // 創建一個新的 UIWindow
        animationWindow = UIWindow(frame: UIScreen.main.bounds)
        // 將新 UIWindow 的 windowLevel 設置為高於主界面
        animationWindow?.windowLevel = .alert + 1
        // 將 AnimationViewController 設置為新 UIWindow 的 rootViewController
        animationWindow?.rootViewController = AnimationViewController()
        
        // 顯示新 UIWindow
        animationWindow?.makeKeyAndVisible()
        
        // 動畫完成後隱藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            UIView.animate(withDuration: 3, animations: {
                // 將層級調整為正常
                self.animationWindow?.windowLevel = .normal
                self.animationWindow?.alpha = 0
            }, completion: { _ in
                // 隱藏動畫視窗
                self.animationWindow?.isHidden = true
                // 釋放動畫視窗
                self.animationWindow = nil
                // 將原來的 UIWindow 重新設置為 key window
                self.window?.makeKeyAndVisible()
            })
        }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
