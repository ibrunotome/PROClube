//
//  ProfileDetailViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 12/29/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class ProfileDetailViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var profile = PFUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        addLeftNavItemOnView()
        addRightNavItemOnView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.profileName.text = self.profile["name"]! as? String
        self.profile["profilePicture"]!.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                self.profilePicture.image = image?.correctlyOrientedImage()
            }
        }
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 3.0;
        self.profilePicture.layer.borderColor = UIColor.grayColor().CGColor
        
        let cssStyle = "<style>body {font-family: Helvetica Neue; font-size: 16px; font-weight: 400;} .personalInfo {font-size: 14px; font-weight: 200; margin-top: -10px;} .jobDate {font-size: 12px; font-weight: 600; text-align: right; margin-top: -10px;} .bioDescription {text-align: justify;}</style>"
        let htmlHeader = "<html><head>\(cssStyle)<meta charset=\"utf-8\"></head><body>"
        let htmlFooter = "</body></html>"
        let email = "<p class=\"personalInfo\"><b>Email:</b> \(self.profile["email"]!)</p>"
        var phone = ""
        if self.profile["phone"] != nil {
            phone = "<p class=\"personalInfo\"><b>Telefone:</b> \(self.profile["phone"]!)</p>"
        }
        var skills = ""
        if self.profile["phone"] != nil {
            skills = "<p class=\"personalInfo\"><b>Habilidades:</b> \((self.profile["skills"] as! [String]).joinWithSeparator(" / "))</p>"
        }
        let bioDescription = "<p class=\"bioDescription\">\(self.profile["bio"]!)</p>"
        
        let htmlString = htmlHeader + email + phone + skills + bioDescription + htmlFooter
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView.scrollView.bounces = false
        self.webView.dataDetectorTypes = [.Link, .PhoneNumber]
        
    }
    
}

