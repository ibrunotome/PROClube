//
//  LSMViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/30/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit

class LSMViewController: UIViewController, UIGestureRecognizerDelegate {
    
    struct LSMProperties {
        static let mainViewOffset: CGFloat = 0.8
        static let mainViewScale: CGFloat = 0.8
        static let leftViewScale: CGFloat = 0.6
        static let maskViewAlpha: CGFloat = 0.9
    }
    
    let leftVC, mainVC: UIViewController
    let leftView, mainView: UIView
    let maskView = UIView()
    
    var tapGes: UITapGestureRecognizer?
    
    init(leftVC: UIViewController, mainVC: UIViewController) {
        self.leftVC = leftVC
        self.mainVC = mainVC
        self.leftView = leftVC.view
        self.mainView = mainVC.view
        super.init(nibName: nil, bundle: nil)
        
        let imageview: UIImageView = UIImageView(frame: self.view.bounds)
        imageview.image = UIImage(named: "leftBackImage")
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        self.view.addSubview(imageview)
        self.view.addSubview(blurView)
        
        self.leftView.backgroundColor = UIColor.clearColor()
        self.leftView.frame = CGRectMake(-UIScreen.width * LSMProperties.mainViewOffset / 2, 0, UIScreen.width * LSMProperties.mainViewOffset, UIScreen.height);
        
        self.maskView.frame = self.view.bounds
        self.maskView.backgroundColor = UIColor.blackColor()
        
        self.view.addSubview(self.leftView)
        self.view.addSubview(self.maskView)
        self.view.addSubview(self.mainView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var slideDegree: CGFloat = 0 {
        didSet {
            if slideDegree < 0 {
                slideDegree = 0
            } else if slideDegree > 100 {
                slideDegree = 100
            }
            
            UIView.beginAnimations(nil, context:nil)
            
            var x = UIScreen.width * (0.5 + LSMProperties.mainViewOffset * slideDegree/100) - UIScreen.width/2 * slideDegree/100 * (1 - LSMProperties.mainViewScale)
            self.mainView.center = CGPoint(x: x, y: self.mainView.center.y)
            
            var scale = 1 - slideDegree/100 * (1 - LSMProperties.mainViewScale)
            self.mainView.transform = CGAffineTransformMakeScale(scale, scale)
            
            x = UIScreen.width * LSMProperties.mainViewOffset / 2 * slideDegree/100
            self.leftView.center = CGPoint(x: x, y: self.leftView.center.y)
            
            scale = LSMProperties.leftViewScale + slideDegree/100 * (1 - LSMProperties.leftViewScale)
            self.leftView.transform = CGAffineTransformMakeScale(scale, scale)
            
            self.maskView.alpha = LSMProperties.maskViewAlpha * (1 - slideDegree/100)
            
            UIView.commitAnimations()
            
            if slideDegree == 0 {
                if self.tapGes != nil {
                    self.mainView.removeGestureRecognizer(self.tapGes!)
                }
            } else if slideDegree == 100 {
                self.tapGes = UITapGestureRecognizer(target: self, action: "slideMenu")
                self.mainView.addGestureRecognizer(self.tapGes!)
            }
        }
    }
    
    func closeSlideMenu() {
        self.slideDegree = 0
    }
    
    func slideMenu() {
        self.slideDegree = 100 - self.slideDegree
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
