//
//  CustomPresentationController.swift
//  GoodThing
//
//  Created by 蔡佳峪 on 2023/9/22.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height * 4 / 5, width: containerView.bounds.width, height: containerView.bounds.height / 5)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
        
        containerView.insertSubview(dimmingView, at: 0)
        dimmingView.addSubview(presentedViewController.view)
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }
    
    @objc func dimmingViewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: dimmingView)
        

        if !presentedViewController.view.frame.contains(location) {
            print("Tap is outside the presented view. ")
            (presentedViewController as? CommentViewController)?.dismissClosure?()
        } else {
            print("Tap is inside the presented view.")
        }
    }
    
    override func dismissalTransitionWillBegin() {
        dimmingView.removeFromSuperview()
    }
}
