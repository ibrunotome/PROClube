//
//  SkillsTableViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/26/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class SkillsTableViewController: UITableViewController {
    
    let user = PFUser.currentUser()
    let searchController = UISearchController(searchResultsController: nil)
    var skillsNames = [String]()
    var filteredSkills = [String]()
    var refresher = UIRefreshControl()
    var activityIndicator = MaterialActivityIndicatorView(style: .Large)
    
    func filterContentForSearchText(searchText: String) {
        self.filteredSkills = self.skillsNames.filter { skill in
            return skill.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        self.title = "Categorias"
        self.addLeftNavItemOnView()
        
        self.searchController.searchBar.barTintColor = UIColor.MKColor.Grey
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.placeholder = "Procurar"
        self.searchController.searchBar.setValue("Cancelar", forKey: "_cancelButtonText")
        self.searchController.searchBar.keyboardAppearance = .Dark
        self.searchController.dimsBackgroundDuringPresentation = false
        self.refresher.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        let sugestButton : UIBarButtonItem = UIBarButtonItem(title: "Sugerir", style: UIBarButtonItemStyle.Plain, target: self, action: "suggestSkill:")
        self.navigationItem.rightBarButtonItem = sugestButton
        self.refresher.attributedTitle = NSAttributedString(string: "Puxe para atualizar")
        self.refresher.addTarget(self, action: "refreshWork:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refresher)
        self.refreshData()
        self.displayAlert("Categorias", messageAlert: "Servem para você ser facilmente encontrado a partir das buscas de outros profissionais e também lhe ajudarão a filtrar os trabalhos que combinam com você :)\n\nDefina até 5 categorias que combinam com você ou sugira uma nova no canto supeior direito")
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return self.filteredSkills.count
        } else {
            return self.skillsNames.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SkillsCell", forIndexPath: indexPath) as! SkillsTableViewCell
        
        var skill: String
        
        if self.searchController.active && self.searchController.searchBar.text != "" {
            skill = self.filteredSkills[indexPath.row]
        } else {
            skill = self.skillsNames[indexPath.row]
        }
        
        cell.textLabelSkill.text = skill

        if ((self.user!["skills"]?.containsObject(skill)) == true) {
            cell.switchSkill.setOn(true, animated: false)
        } else {
            cell.switchSkill.setOn(false, animated: false)
        }
        
        return cell
        
    }
    
    /**
     Show a refresher element when user pull down the table
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    func refreshWork(sender:AnyObject) {
        self.refreshData()
        self.refresher.endRefreshing()
    }
    
    /**
     Make the query, fill the skill list and refresh table data
     - returns: Void
     */
    
    func refreshData() {
        
        let querySkills = PFQuery(className: "Skill")
        querySkills.limit = 1000
        querySkills.cachePolicy = .CacheThenNetwork
        querySkills.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        if !self.skillsNames.contains(object["name"] as! String) {
                            self.skillsNames.append(object["name"] as! String)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            self.skillsNames.sortInPlace()
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            
        })
        
    }
    
    /**
     Create a new category
     - parameter sender: AnyObject
     - returns: Void
     */
    
    func suggestSkill(sender: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Nova Categoria", message: "Não encontrou uma categoria que combine com o que você faz? Adicione-a abaixo", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            textField.keyboardAppearance = .Dark
            let suggestAction: UIAlertAction = UIAlertAction(title: "Sugerir", style: .Default) { action -> Void in
                
                textField.text = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if textField.text != "" {
                let newSkill = PFObject(className: "Skill")
                    newSkill["name"] = textField.text
                    newSkill.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            self.refreshData()
                            self.displayAlert("Feito :)", messageAlert: "Categoria cadastrada")
                        } else {
                            self.displayAlert("Oops :(", messageAlert: "Não foi possível adicionar")
                            print(error)
                        }
                    }
                } else {
                    self.displayAlert("Oops :(", messageAlert: "A Categoria não pode ficar em branco!")
                }
            }
            
            actionSheetController.addAction(suggestAction)
        }
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

}
