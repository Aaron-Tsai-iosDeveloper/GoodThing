//
//  MainTabBarController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/10/3.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = .systemBrown
        feedbackGenerator.prepare()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("tabBarController(_:shouldSelect:) called")
        feedbackGenerator.impactOccurred()
        var targetVC: UIViewController?
        if let navController = viewController as? UINavigationController {
            targetVC = navController.topViewController
        } else {
            targetVC = viewController
        }
        
       
        if targetVC is TasksViewController {
            print("TasksViewController is detected")
        } else if targetVC is FetchMemoryViewController {
            print("FetchMemoryViewController is detected")
        } else if targetVC is FetchGroupViewController {
            print("FetchGroupViewController is detected")
        } else if targetVC is UserProfileViewController {
            print("UserProfileViewController is detected")
        }
        
        
        if targetVC is TasksViewController ||
           targetVC is FetchMemoryViewController ||
           targetVC is FetchGroupViewController ||
           targetVC is UserProfileViewController {
            
            let userId = UserDefaults.standard.string(forKey: "userId")
            
            if userId == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let loginVC = storyboard.instantiateViewController(withIdentifier: "UserLoginViewController") as? UserLoginViewController {
                    self.present(loginVC, animated: true, completion: nil)
                    return false
                } else {
                    print("Error: Failed to instantiate UserLoginViewController from storyboard.")
                }
            }
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        feedbackGenerator.impactOccurred()
    }
}
