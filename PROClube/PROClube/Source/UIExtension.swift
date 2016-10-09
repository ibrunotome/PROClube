//
//  UIStoryboardExtension.swift
//  PROClube
//
//  Created by Bruno Tomé on 9/8/15.
//  Copyright (c) 2015 Mobile BR. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class var mainStoryboard: UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func menuViewController() -> MenuViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("MenuViewController") as? MenuViewController
    }
    
    class func infoViewController() -> InfoViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("InfoViewController") as? InfoViewController
    }
    
    class func tutorialViewController() -> TutorialViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("TutorialViewController") as? TutorialViewController
    }
    
    class func feedTableViewController() -> FeedTableViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("FeedTableViewController") as? FeedTableViewController
    }
    
    class func feedDetailViewController() -> FeedDetailViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("FeedDetailViewController") as? FeedDetailViewController
    }
    
    class func postJobViewController() -> PostJobViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("PostJobViewController") as? PostJobViewController
    }
    
    class func loginViewController() -> LoginViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as? LoginViewController
    }
    
    class func settingsViewController() -> SettingsViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController
    }
    
    class func profileViewController() -> ProfileViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("ProfileViewController") as? ProfileViewController
    }
    
    class func skillsTableViewController() -> SkillsTableViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("SkillsTableViewController") as? SkillsTableViewController
    }
    
    class func changePasswordViewController() -> ChangePasswordViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("ChangePasswordViewController") as? ChangePasswordViewController
    }
    
    class func profileTableViewController() -> ProfileTableViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("ProfileTableViewController") as? ProfileTableViewController
    }
    
    class func profileDetailViewController() -> ProfileDetailViewController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("ProfileDetailViewController") as? ProfileDetailViewController
    }
    
    class func mainNavigationController() -> UINavigationController? {
        return mainStoryboard.instantiateViewControllerWithIdentifier("MainNavigationController") as? UINavigationController
    }
}

extension UIScreen {
    static var size: CGSize {
        return UIScreen.mainScreen().bounds.size
    }
    
    static var width: CGFloat {
        return UIScreen.mainScreen().bounds.size.width
    }
    
    static var height: CGFloat {
        return UIScreen.mainScreen().bounds.size.height
    }
}

extension UIViewController {
    
    public func getError(code: Int) -> String {
        switch code {
        case 100:
            return "Falha ao conectar ao servidor, cheque se a conexão com a internet está ativa"
        case 101:
            return "Username ou senha inválidos"
        case 124:
            return "Falha ao conectar ao servidor, cheque se a conexão com a internet está ativa"
        case 125:
            return "Email inválido"
        case 200:
            return "Username inválido"
        case 201:
            return "Senha inválida"
        case 202:
            return "Esse nome de usuário já foi escolhido"
        case 203:
            return "Esse email já está registrado"
        case 204:
            return "Email inválido"
        case 205:
            return "Email não encontrado"
        case 206, 209:
            return "Sessão inválida"
        default:
            return "Erro desconhecido"
        }
    }
    
    public func swipeBack(sender: UISwipeGestureRecognizer) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Right:
            tempAppDelegate.mainNavigationController.popViewControllerAnimated(true)
        break
        default:
            break
        }
    }
    
    public func showMenu(sender: UISwipeGestureRecognizer) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        tempAppDelegate.lsmVC?.slideMenu()
    }
    
    public func displayAlert(title:String, messageAlert:String) {
        
        let alert = UIAlertController(title: title, message: messageAlert, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    public func addMenuNavItemOnView() {
        // hide default navigation bar button item
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false
        let buttonBack: UIButton = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(0, 0, 40, 40)
        buttonBack.setImage(UIImage(named:"menu.png"), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "slideMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
    }
    
    public func addRightNavItemOnView() {
        // hide default navigation bar button item
        self.navigationItem.rightBarButtonItem = nil
        let buttonInfo: UIButton = UIButton(type: UIButtonType.Custom)
        buttonInfo.frame = CGRectMake(self.view.bounds.width, 0, 40, 40)
        buttonInfo.setImage(UIImage(named:"info.png"), forState: UIControlState.Normal)
        buttonInfo.addTarget(self, action: "showInfo:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonInfo)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
    }
    
    public func addTutorialNavItemOnView() {
        // hide default navigation bar button item
        self.navigationItem.rightBarButtonItem = nil
        let buttonInfo: UIButton = UIButton(type: UIButtonType.Custom)
        buttonInfo.frame = CGRectMake(self.view.bounds.width, 0, 40, 40)
        buttonInfo.setImage(UIImage(named:"info.png"), forState: UIControlState.Normal)
        buttonInfo.addTarget(self, action: "showTutorial:", forControlEvents: UIControlEvents.TouchUpInside)
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonInfo)
        self.navigationItem.setRightBarButtonItem(rightBarButtonItem, animated: false)
    }
    
    public func addLeftNavItemOnView() {
        
        // hide default navigation bar button item
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = false
        
        let buttonBack: UIButton = UIButton(type: UIButtonType.Custom)
        buttonBack.frame = CGRectMake(0, 0, 40, 40)
        buttonBack.setImage(UIImage(named:"backButton.png"), forState: UIControlState.Normal)
        buttonBack.addTarget(self, action: "leftNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
        
        self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)
        
    }
    
    public func slideMenu(sender: UIBarButtonItem) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        tempAppDelegate.lsmVC?.slideMenu()
    }
    
    public func showInfo(sender: UIBarButtonItem) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc: InfoViewController = UIStoryboard.infoViewController()!
        tempAppDelegate.lsmVC!.closeSlideMenu()
        tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
    }
    
    public func showTutorial(sender: UIBarButtonItem) {
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc: TutorialViewController = UIStoryboard.tutorialViewController()!
        tempAppDelegate.lsmVC!.closeSlideMenu()
        tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
    }
    
    public func leftNavButtonClick(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) { // became first responder
        
        //move textfields up
        let myScreenRect: CGRect = UIScreen.mainScreen().bounds
        let keyboardHeight : CGFloat = 276
        
        UIView.beginAnimations("animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.view.frame
        if (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        
        frame.origin.y = -needToMove
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        //move textfields back down
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    public func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    public func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        let newImageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: newImageRef!)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

extension UIImage {
    
    func correctlyOrientedImage() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.drawInRect(CGRectMake(0, 0, self.size.width, self.size.height))
        let normalizedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return normalizedImage;
    }
    
}

extension String {
    func isEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}

extension SkillsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension FeedTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension ProfileTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}