//
//  FeedDetailViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 11/4/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class FeedDetailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let user = PFUser.currentUser()
    let webView = UIWebView()
    let interested = UIButton()
    var job: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addLeftNavItemOnView()
        self.addTutorialNavItemOnView()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        let cssStyle = "<style>body {padding: 0 1%; font-family: Helvetica Neue; font-size: 16px; font-weight: 400; background-color: #ffffff;} .jobTitle {text-align: center; font-family: Helvetica Neue; letter-spacing: -1px; font-weight: bold;} .info {font-size: 15px;  margin-top: -10px;} .jobDate {font-size: 12px; font-weight: 600; text-align: right; margin-top: -10px;} .jobDescription {text-align: justify;}</style>"
        let htmlHeader = "<html><head><title></title>\(cssStyle)</head><body>"
        let htmlFooter = "</body></html>"
        let jobTitle = "<h3 class=\"jobTitle\">" + (self.job!["name"] as! String).uppercaseString + "</h3>"
        let companyName = "<p class=\"info\"><b>Postado por:</b> " + (self.job!["companyName"] as! String) + "</p>"
        let companyLocation = "<p class=\"info\"><b>Localização:</b> " + (self.job!["locationString"] as! String) + "</p>"
        let phoneString = (self.job!["companyPhone"] != nil) ? self.job!["companyPhone"] as! String : ""
        let companyEmail = "<p class=\"info\"><b>E-mail:</b> " + (self.job!["companyEmail"] as! String) + "</p>"
        let companyPhone = "<p class=\"info\"><b>Contato:</b> " + phoneString + "</p>"
        let jobPayment = "<p class=\"info\"><b>Pagamento:</b> " + (self.job!["payment"] as! String) + "</p>"
        let jobDescription = "<p class=\"jobDescription\"><b>Descrição</b><br>" + (self.job!["description"] as! String).stringByReplacingOccurrencesOfString("\n\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("\n", withString: "<br>", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("Requisitos", withString: "<br><b>Requisitos</b>", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByReplacingOccurrencesOfString("Benefícios", withString: "<br><b>Benefícios</b>", options: NSStringCompareOptions.LiteralSearch, range: nil) + "</p>"
        let dateCreated = self.job!.createdAt!
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let jobDate = "<p class=\"jobDate\">\(NSString(format: "%@", dateFormat.stringFromDate(dateCreated)))</p>"
        let htmlString = htmlHeader + jobTitle + companyName + companyLocation + companyEmail + companyPhone + jobPayment + jobDate + jobDescription + htmlFooter
        self.webView.loadHTMLString(htmlString, baseURL: nil)
        self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50)
        self.webView.scrollView.bounces = false
        self.webView.dataDetectorTypes = [.Link, .PhoneNumber]
        self.view.addSubview(self.webView)
        self.interested.frame = CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)
        if self.job!["interested"]?.containsObject((self.user?.objectId)!) == true {
            self.interested.backgroundColor = UIColor.MKColor.Green
            self.interested.setTitle("Favorito!", forState: .Normal)
        } else {
            self.interested.backgroundColor = UIColor.MKColor.Orange
            self.interested.setTitle("Gostou?", forState: .Normal)
        }
        self.interested.addTarget(self, action: "peopleInterested:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.interested)
        
    }
    
    /**
     Show the alert dialog for who are interested on the job
     - parameter sender: UIButton
     - returns: Void
     */
    
    func peopleInterested(sender: UIButton) {
        
        let alert = UIAlertController(title: "Gostou deste \(self.job!["type"]!)?", message: "Marque como favorito ou entre em contato:", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in }
        
        let favoriteAction: UIAlertAction = UIAlertAction(title: "Favorito", style: .Default) { action -> Void in
            if self.job!["interested"]?.containsObject((self.user?.objectId)!) == true {
                self.interested.backgroundColor = UIColor.MKColor.Orange
                self.job!.removeObject(((self.user?.objectId)! as String), forKey: "interested")
                self.user!.removeObject((self.job?.objectId)!, forKey: "interested")
                self.interested.setTitle("Gostou?", forState: .Normal)
            } else {
                let query: PFQuery = PFInstallation.query()!
                query.whereKey("installationUser", equalTo: self.job!["owner"]! as! String)
                let data = [
                    "alert" : "\(self.user!["name"]!) se interessou pelo \(self.job!["type"]!) que você postou!",
                    "badge" : "Increment",
                    "sound" : "default"
                ]
                let push = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackground()
                
                self.interested.backgroundColor = UIColor.MKColor.Green
                self.job!.addUniqueObject(((self.user?.objectId)! as String), forKey: "interested")
                self.user!.addUniqueObject((self.job?.objectId)!, forKey: "interested")
                self.interested.setTitle("Favorito!", forState: .Normal)
            }
            
            self.job?.saveInBackground()
            self.user?.saveInBackground()
        }
        
        let shareAction: UIAlertAction = UIAlertAction(title: "Publicar", style: .Default) { action -> Void in
            let jobType = (self.job!["offering"] as! Bool == true) ? "Oferta" : "Procura"
            let shareString = "\(jobType) de \(self.job!["type"]!) no PROClube.\n\n\(self.job!["companyName"]!)\nLocalização: \(self.job!["locationString"]!)\nContato: \(self.job!["companyEmail"]!)\n\nFunção: \(self.job!["name"]!).\n\nDescrição: \(self.job!["description"]!)"
            let objectsToShare = [shareString]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
                self.view.bounds.size.height, 1.0, 1.0)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        
        /// Create and add a third option action
        let contactAction: UIAlertAction = UIAlertAction(title: "Entrar em Contato", style: .Default) { action -> Void in
            self.sendEmail(self.job!["companyEmail"] as! String)
        }
        
        /// Create and add fourth option action
        let editAction: UIAlertAction = UIAlertAction(title: "Editar", style: .Default) { action -> Void in
            let vc: PostJobViewController = UIStoryboard.postJobViewController()!
            vc.existingJob = self.job
            let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            tempAppDelegate.mainNavigationController.popViewControllerAnimated(false)
            tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
        }
        
        /// Create and add the five option action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Apagar", style: .Destructive) { action -> Void in
            self.confirmDelete(self.job!)
        }
        
        /// Create and add the sixth option action
        let seeInterestedAction: UIAlertAction = UIAlertAction(title: "Ver Interessados", style: .Default) { action -> Void in
            let vc: ProfileTableViewController = UIStoryboard.profileTableViewController()!
            vc.peopleInterested = self.job!["interested"]! as! [String]
            let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(favoriteAction)
        alert.addAction(shareAction)
        alert.addAction(contactAction)
        
        if job!["owner"] as? String == self.user?.objectId {
            alert.addAction(seeInterestedAction)
            alert.addAction(editAction)
            alert.addAction(deleteAction)
        }
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
            self.view.bounds.size.height, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    /**
     Show the app Mail screen with the email of post owner
     - parameter email: String containig the email of post owner
     - returns: Void
     */
    
    func sendEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject("Interessado no Trabalho")
            mail.setMessageBody("<p>Olá!...</p>", isHTML: true)
            self.presentViewController(mail, animated: true, completion: nil)
        } else {
            self.displayAlert("Oops :(", messageAlert: "Ocorreu um erro ao acessar o aplicativo de email :(")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Show confirm dialog for delete job
     - parameter job: PFObject
     - returns: Void
     */
    
    func confirmDelete(job: PFObject) {
        
        let alert = UIAlertController(title: "Apagar \(job["type"]!)", message: "Tem certeza que quer apagar permanentemente esse \(job["type"]!)?", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in }
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Apagar", style: .Destructive) { action -> Void in
            self.user!["interested"]!.removeObject(job.objectId!)
            self.user!.saveInBackground()
            job.deleteInBackground()
            let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            tempAppDelegate.mainNavigationController.popViewControllerAnimated(false)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
            self.view.bounds.size.height, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
