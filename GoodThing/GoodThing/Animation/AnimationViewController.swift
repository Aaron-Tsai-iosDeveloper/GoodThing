//
//  AnimationViewController.swift
//  STYLiSH
//
//  Created by 蔡佳峪 on 2023/9/7.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import Foundation
import UIKit


// 動畫界面
class AnimationViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始背景色設為白色
        self.view.backgroundColor = UIColor.yellow
        
        // 使用UILabel來作為品牌標誌
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 70))
        label.center = self.view.center
        label.text = "好事GoodThing"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30) // 根據需要調整字體大小
        self.view.addSubview(label)
        
        // 平滑過渡背景色
        UIView.animate(withDuration: 2.0) {
            self.view.backgroundColor = UIColor(red: 141/255, green: 86/255, blue: 49/255, alpha: 1.0)
        }

        // 3D標誌轉換
        let transform = CATransform3DIdentity
        label.layer.transform = CATransform3DRotate(transform, .pi / 4, 0, 1, 0)
        UIView.animate(withDuration: 2.0) {
            label.layer.transform = CATransform3DIdentity
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.view.isHidden {
            // 如果視圖被隱藏，可以在這裡執行相關的處理
            print("視圖已經隱藏")
        } else {
            // 如果視圖不是隱藏的，可以在這裡執行相關的處理
            print("視圖是可見的")
        }
    }

}

