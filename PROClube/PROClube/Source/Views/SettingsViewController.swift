//
//  SettingsViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/22/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showMenu:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.title = "Opções"
        
        self.addMenuNavItemOnView()
        self.addTutorialNavItemOnView()
        self.tableView.delegate  = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = UITableViewCell()
        headerCell.textLabel!.textColor = UIColor.grayColor()
        headerCell.backgroundColor = UIColor.clearColor()
        
        switch (section) {
            
        case 0:
            headerCell.textLabel!.text = "Meus Favoritos"
            break
            
        case 1:
            headerCell.textLabel!.text = "Meus Posts"
            break
            
        case 2:
            headerCell.textLabel!.text = "Configurações"
            break
            
        default:
            headerCell.textLabel!.text = ""
            break
            
        }
        
        return headerCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 2
        case 2:
            return 4
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("menuItem")
        
        cell!.textLabel!.font = UIFont.systemFontOfSize(20.0)
        cell!.backgroundColor = UIColor.clearColor()
        cell!.textLabel!.textColor = UIColor.blackColor()
        cell!.indentationLevel = 2
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell?.textLabel!.text = "Contratando"
            } else if indexPath.row == 1 {
                cell?.textLabel!.text = "Procurando"
            }
            break
        case 1:
            if indexPath.row == 0 {
                cell?.textLabel!.text = "Contratando"
            } else if indexPath.row == 1 {
                cell?.textLabel!.text = "Procurando"
            }
            break
        case 2:
            if indexPath.row == 0 {
                cell?.textLabel!.text = "Editar Perfil"
            } else if indexPath.row == 1 {
                cell?.textLabel!.text = "Editar Categorias"
            } else if indexPath.row == 2 {
                cell?.textLabel!.text = "Alterar Senha"
            } else if indexPath.row == 3 {
                cell?.textLabel!.text = "Sair"
                cell?.textLabel?.textColor = UIColor.redColor()
            }
            break
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let vc: FeedTableViewController = UIStoryboard.feedTableViewController()!
                vc.filterText = "Apenas Meus Favoritos"
                vc.typeSearch = "offering"
                tempAppDelegate.mainNavigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                let vc: FeedTableViewController = UIStoryboard.feedTableViewController()!
                vc.filterText = "Apenas Meus Favoritos"
                vc.typeSearch = "searching"
                tempAppDelegate.mainNavigationController?.pushViewController(vc, animated: true)
            }
            break
        case 1:
            if indexPath.row == 0 {
                let vc: FeedTableViewController = UIStoryboard.feedTableViewController()!
                vc.filterText = "Apenas Meus Posts"
                vc.typeSearch = "offering"
                tempAppDelegate.mainNavigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                let vc: FeedTableViewController = UIStoryboard.feedTableViewController()!
                vc.filterText = "Apenas Meus Posts"
                vc.typeSearch = "searching"
                tempAppDelegate.mainNavigationController?.pushViewController(vc, animated: true)
            }
            break
        case 2:
            if indexPath.row == 0 {
                let vc: ProfileViewController = UIStoryboard.profileViewController()!
                tempAppDelegate.mainNavigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                let vc: SkillsTableViewController = UIStoryboard.skillsTableViewController()!
                tempAppDelegate.mainNavigationController.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {
                let vc: ChangePasswordViewController = UIStoryboard.changePasswordViewController()!
                tempAppDelegate.mainNavigationController.pushViewController(vc, animated: true)
            } else if indexPath.row == 3 {
                PFUser.logOut()
                self.user = nil
                let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                UIApplication.sharedApplication().keyWindow?.rootViewController = loginViewController
            }
            break
        default:
            break
        }
        
    }
}
