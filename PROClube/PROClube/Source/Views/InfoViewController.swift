//
//  InfoViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 12/27/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.title = "PROClube"
        self.addLeftNavItemOnView()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let cssStyle = "<style>body {font-family: Helvetica Neue; font-size: 16px; font-weight: 400;} .jobTitle {text-align: center; font-family: Helvetica Neue; letter-spacing: -1px; font-weight: bold;} .companyName {font-size: 16px; font-weight: 400;} .location {font-size: 14px; font-weight: 200; margin-top: -10px;} .jobDate {font-size: 12px; font-weight: 600; text-align: right; margin-top: -10px;} .jobDescription {text-align: justify;}</style>"
        let htmlHeader = "<html><head>\(cssStyle)</head><body>"
        let htmlFooter = "</body></html>"
        let jobTitle = "<h3 class=\"jobTitle\">PROClube<br>Clube dos Profissionais</h3>"
        let jobDescription = "<p class=\"jobDescription\">Este aplicativo foi feito para procurar ou encontrar ofertas de freelas, empregos, estágios, serviços particulares e qualquer tipo de oportunidade de trabalho próximo a sua localização.</p>"
            + "<p class=\"jobDescription\">PROClube foi criado pela Mobile BR, conheça mais sobre nós no link abaixo:</p>"
        
        let htmlString = htmlHeader + jobTitle + jobDescription + htmlFooter
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView.scrollView.bounces = false
        self.webView.dataDetectorTypes = .Link
        
    }
    
}
