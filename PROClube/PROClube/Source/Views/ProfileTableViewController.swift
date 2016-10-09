//
//  ProfileTableViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 12/29/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class ProfileTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let user = PFUser.currentUser()
    
    var profiles = [PFUser]()
    var filteredProfiles = [PFUser]()
    var peopleInterested = [String]()
    let searchController = UISearchController(searchResultsController: nil)
    var queryProfiles = PFQuery(className: "_User")
    var refresh = UIRefreshControl()
    var activityIndicator = MaterialActivityIndicatorView(style: .Large)
    
    func filterContentForSearchText(searchText: String) {
        self.filteredProfiles = self.profiles.filter { profile in
            return (profile["name"] as! String).lowercaseString.containsString(searchText.lowercaseString)
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        self.title = "Interessados"
        self.addLeftNavItemOnView()
        self.addRightNavItemOnView()
        
        self.searchController.searchBar.barTintColor = UIColor.MKColor.Grey
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = "Procurar"
        self.searchController.searchBar.setValue("Cancelar", forKey: "_cancelButtonText")
        self.searchController.searchBar.keyboardAppearance = .Dark
        self.searchController.dimsBackgroundDuringPresentation = false
        self.refresh.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.refresh.attributedTitle = NSAttributedString(string: "Puxe para atualizar")
        self.refresh.addTarget(self, action: "refresherWork:", forControlEvents: UIControlEvents.AllEvents)
        self.tableView?.addSubview(self.refresh)
        self.configureQuery()
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 125
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return self.filteredProfiles.count
        } else {
            return self.profiles.count
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.activityIndicator.center = cell.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var profile: PFUser
        
        if self.searchController.active && self.searchController.searchBar.text != "" {
            profile = self.filteredProfiles[indexPath.row]
        } else {
            profile = self.profiles[indexPath.row]
        }
        
        //Create and add a third option action
        let contactAction = UITableViewRowAction(style: .Normal, title: "Contato") { action, index in
            self.sendEmail(profile["email"] as! String)
        }
        contactAction.backgroundColor = UIColor.MKColor.Blue
        
        return [contactAction]
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! ProfileTableViewCell
        
        var profile: PFUser
        
        if self.searchController.active && self.searchController.searchBar.text != "" {
            profile = self.filteredProfiles[indexPath.row]
        } else {
            profile = self.profiles[indexPath.row]
        }
        
        cell.profileName.text = profile["name"]?.uppercaseString
        cell.profileDescription.text = (profile["bio"] as! String)
        cell.profilePicture.image = UIImage(named: "avatar.png")
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2
        cell.profilePicture.clipsToBounds = true
        
        profile["profilePicture"]!.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.profilePicture.image = image?.correctlyOrientedImage()
            }
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc: ProfileDetailViewController = UIStoryboard.profileDetailViewController()!
        
        var profile: PFUser
        
        if self.searchController.active && self.searchController.searchBar.text != "" {
            profile = self.filteredProfiles[indexPath.row]
        } else {
            profile = self.profiles[indexPath.row]
        }
        
        vc.title = profile["name"] as? String
        vc.profile = profile
        tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
    }
    
    /**
     Configure the query with the parameters
     - returns: Void
     */
    
    func configureQuery() {
        self.queryProfiles.whereKey("objectId", containedIn: self.peopleInterested)
        self.queryProfiles.orderByAscending("createdAt")
        self.profiles.removeAll()
        self.refreshData()
    }
    
    /**
     Show a refresher element when user pull down the table
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    func refresherWork(sender:AnyObject) {
        self.profiles.removeAll()
        self.refreshData()
    }
    
    /**
     Make the query, fill the profiles list and refresh table data
     - returns: Void
     */
    
    private func refreshData() {
        var flagJobRepeated = false
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.queryProfiles.cancel()
        self.queryProfiles.cachePolicy = .CacheThenNetwork
        self.queryProfiles.findObjectsInBackgroundWithBlock({(objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    
                    if objects.count == 0 {
                        self.displayAlert("Oops :(", messageAlert: "Parece que não há interessados ainda")
                    }
                    
                    for object in objects {
                        flagJobRepeated = false
                        for profile in self.profiles {
                            if profile.objectId == object.objectId {
                                flagJobRepeated = true
                            }
                        }
                        
                        if !flagJobRepeated {
                            self.profiles.append(object as! PFUser)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            if self.refresh.refreshing {
                self.refresh.endRefreshing()
            }
            
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        })
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
            self.displayAlert("Oops :(", messageAlert: "Ocorreu um erro ao acessar o aplicativo de email")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}