//
//  MenuViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/30/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.dataSource = self
        self.tableview.delegate  = self
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableview.backgroundColor = UIColor.clearColor()
        self.tableview.bounces = false

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = UITableViewCell()
        headerCell.textLabel!.textColor = UIColor.grayColor()
        headerCell.backgroundColor = UIColor.clearColor()
        
        switch (section) {
            
        case 0:
            headerCell.textLabel!.text = "Todos os Trabalhos"
            break
        case 1:
            headerCell.textLabel!.text = "Quero Contratar"
            break
        case 2:
            headerCell.textLabel!.text = "Quero Trabalhar"
            break
        case 3:
            headerCell.textLabel!.text = "Outros"
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
        default:
            return 4
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("menuItem", forIndexPath: indexPath)
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel!.font = UIFont.systemFontOfSize(20.0)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel!.textColor = UIColor.whiteColor()
        cell.indentationLevel = 2
        
        switch indexPath.section {
            
        case 0:
            if indexPath.row == 0 {
                cell.textLabel!.text = "Vagas"
            } else if indexPath.row == 1 {
                cell.textLabel!.text = "Profissionais"
            }
        break
            
        case 1:
            if indexPath.row == 0 {
                cell.textLabel!.text = "Freela"
            } else if (indexPath.row == 1) {
                cell.textLabel!.text = "Emprego"
            } else if (indexPath.row == 2) {
                cell.textLabel!.text = "Estágio"
            } else if indexPath.row == 3 {
                cell.textLabel!.text = "Serviço Particular"
                cell.textLabel!.font = UIFont.systemFontOfSize(19.0)
            }
        break
            
        case 2:
            if indexPath.row == 0 {
                cell.textLabel!.text = "Freela"
            } else if (indexPath.row == 1) {
                cell.textLabel!.text = "Emprego"
            } else if (indexPath.row == 2) {
                cell.textLabel!.text = "Estágio"
            } else if indexPath.row == 3 {
                cell.textLabel!.text = "Serviço Particular"
                cell.textLabel!.font = UIFont.systemFontOfSize(19.0)
            }
        break
            
        case 3:
            if indexPath.row == 0 {
                cell.textLabel!.text = "Meu Perfil"
            } else if indexPath.row == 1 {
                cell.textLabel!.text = "Categorias"
            } else if indexPath.row == 2 {
                cell.textLabel!.text = "Tutorial"
            } else if indexPath.row == 3 {
                cell.textLabel!.text = "Sair"
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
        tempAppDelegate.mainNavigationController.popViewControllerAnimated(false)
        
        switch indexPath.section {
            
        case 0:
            let vc: FeedTableViewController = UIStoryboard.feedTableViewController()!
            
            if indexPath.row == 0 {
                vc.typeSearch = "offering"
            } else if indexPath.row == 1 {
                vc.typeSearch = "searching"
            }
            
            tempAppDelegate.lsmVC!.closeSlideMenu()
            tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: false)
        break
            
        case 1:
            let vc: PostJobViewController = UIStoryboard.postJobViewController()!
            vc.postType = "Oferecer"
            
            if indexPath.row == 0 {
                vc.jobType = "Freela"
            } else if indexPath.row == 1 {
                vc.jobType = "Emprego"
            } else if indexPath.row == 2 {
                vc.jobType = "Estágio"
            } else if indexPath.row == 3 {
                vc.jobType = "Serviço Particular"
            }
            
            tempAppDelegate.lsmVC.closeSlideMenu()
            tempAppDelegate.mainNavigationController.pushViewController(vc, animated: false)
        break
            
        case 2:
            let vc: PostJobViewController = UIStoryboard.postJobViewController()!
            vc.postType = "Procurar"
            
            if indexPath.row == 0 {
                vc.jobType = "Freela"
            } else if indexPath.row == 1 {
                vc.jobType = "Emprego"
            } else if indexPath.row == 2 {
                vc.jobType = "Estágio"
            } else if indexPath.row == 3 {
                vc.jobType = "Serviço Particular"
            }
            
            tempAppDelegate.lsmVC.closeSlideMenu()
            tempAppDelegate.mainNavigationController.pushViewController(vc, animated: false)
        break
            
        case 3:
            if indexPath.row == 0 {
                let vc: SettingsViewController = UIStoryboard.settingsViewController()!
                tempAppDelegate.lsmVC.closeSlideMenu()
                tempAppDelegate.mainNavigationController.pushViewController(vc, animated: false)
            } else if indexPath.row == 1 {
                let vc: SkillsTableViewController = UIStoryboard.skillsTableViewController()!
                tempAppDelegate.lsmVC.closeSlideMenu()
                tempAppDelegate.mainNavigationController.pushViewController(vc, animated: false)
            } else if indexPath.row == 2 {
                let vc: TutorialViewController = UIStoryboard.tutorialViewController()!
                tempAppDelegate.lsmVC.closeSlideMenu()
                tempAppDelegate.mainNavigationController.pushViewController(vc, animated: false)
            } else if indexPath.row == 3 {
                PFUser.logOut()
                self.user = nil
                let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                UIApplication.sharedApplication().keyWindow!.rootViewController = loginViewController
            }
        break
            
        default:
            break
            
        }
        
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath)
        cell!.contentView.backgroundColor = UIColor.grayColor()
    }
    
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell  = tableView.cellForRowAtIndexPath(indexPath)
        cell!.contentView.backgroundColor = .clearColor()
    }
    
    @IBAction func rateApp(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1071254900&mt=8)")!);
    }
}
