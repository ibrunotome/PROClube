//
//  LoginViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 9/8/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: MKTextField!
    @IBOutlet weak var password: MKTextField!
    @IBOutlet weak var forgotPassword: UIButton!
    
    /// Loading activity indicator
    let activityIndicator = MaterialActivityIndicatorView(style: .Large)
    /// Controller of background movie
    let moviePlayerController = AVPlayerViewController()
    /// Player of background movie
    var aPlayer: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = PFUser.currentUser()
        
        if user != nil {
            let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let leftVC: MenuViewController = UIStoryboard.menuViewController()!
            tempAppDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            tempAppDelegate.window!.backgroundColor = UIColor.whiteColor()
            tempAppDelegate.window!.makeKeyAndVisible()
            tempAppDelegate.mainNavigationController = UIStoryboard.mainNavigationController()!
            tempAppDelegate.lsmVC = LSMViewController(leftVC: leftVC, mainVC: tempAppDelegate.mainNavigationController)
            tempAppDelegate.window!.rootViewController = tempAppDelegate.lsmVC
        }
        
        self.navigationController?.navigationBar.hidden = true
        let placeholderUsername = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        let placeholderPassword = NSAttributedString(string: "Senha", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        playBackgroundMovie()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPlayToEndTime", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

        // No border, no shadow, floatingPlaceholderEnabled
        self.username.layer.borderColor = UIColor.clearColor().CGColor
        self.username.floatingPlaceholderEnabled = true
        self.username.placeholder = "Username"
        self.username.attributedPlaceholder = placeholderUsername
        self.username.tintColor = UIColor.whiteColor()
        self.username.rippleLocation = .Right
        self.username.cornerRadius = 0
        self.username.bottomBorderEnabled = true
        
        self.password.layer.borderColor = UIColor.clearColor().CGColor
        self.password.floatingPlaceholderEnabled = true
        self.password.placeholder = "Senha"
        self.password.attributedPlaceholder = placeholderPassword
        self.password.tintColor = UIColor.whiteColor()
        self.password.rippleLocation = .Right
        self.password.cornerRadius = 0
        self.password.bottomBorderEnabled = true
    
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func textFieldDidBeginEditing(textField: UITextField) {
        
        self.forgotPassword.hidden = true
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
    
    override func textFieldDidEndEditing(textField: UITextField) {
        
        if self.password.text == "" {
            self.forgotPassword.hidden = false
        }
        
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.view.frame
        frame.origin.y = 0
        self.view.frame = frame
        UIView.commitAnimations()
    }
    
    /**
     Play the background movie of view
     - returns: Void
     */
    
    func playBackgroundMovie(){
        let url = NSBundle.mainBundle().URLForResource("backgroundLogin", withExtension: "mp4")
        self.aPlayer = AVPlayer(URL: url!)
        self.moviePlayerController.player = aPlayer
        self.moviePlayerController.view.frame = view.frame
        self.moviePlayerController.view.sizeToFit()
        self.moviePlayerController.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.moviePlayerController.showsPlaybackControls = false
        self.aPlayer.play()
        self.aPlayer.muted = true
        self.view.insertSubview(self.moviePlayerController.view, atIndex: 0)
    }
    
    /**
     Loop in the video if it end
     - returns: Void
     */
    
    func didPlayToEndTime(){
        self.aPlayer.seekToTime(CMTimeMakeWithSeconds(0, 1))
        self.aPlayer.play()
    }
    
    /**
     Try login
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func login(sender: AnyObject) {
        
        // Trim username and password
        self.username.text = self.username.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.password.text = self.password.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if self.username.text == "" || self.password.text == nil {
            self.displayAlert("Oops :(", messageAlert: "Você não pode deixar nenhum campo em branco!")
        } else {
            self.activityIndicator.center = self.view.center
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            PFUser.logInWithUsernameInBackground(self.username.text!, password:self.password.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation["installationUser"] = PFUser.currentUser()!.objectId
                    currentInstallation.saveInBackground()
                    let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let leftVC: MenuViewController = UIStoryboard.menuViewController()!
                    tempAppDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                    tempAppDelegate.window!.backgroundColor = UIColor.whiteColor()
                    tempAppDelegate.window!.makeKeyAndVisible()
                    tempAppDelegate.mainNavigationController = UIStoryboard.mainNavigationController()!
                    tempAppDelegate.lsmVC = LSMViewController(leftVC: leftVC, mainVC: tempAppDelegate.mainNavigationController)
                    tempAppDelegate.window!.rootViewController = tempAppDelegate.lsmVC
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    let erroString = self.getError((error?.code)!)
                    self.displayAlert("Oops :(", messageAlert: "\(erroString)")
                }
            }
        }
    }
    
    /**
     Show the screen for SignUp
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func showSingupView(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
        self.dismissViewControllerAnimated(false, completion: nil)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    /**
     Show the popUp for user reset password
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func resetPasswordPressed(sender: AnyObject) {
        
        let titlePrompt = UIAlertController(title: "Redefinir Senha",
            message: "Digite o email que foi usado no momento do cadastro:",
            preferredStyle: .Alert)
        
        var titleTextField: UITextField?
        titlePrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
            titleTextField = textField
            textField.placeholder = "Email"
            textField.keyboardAppearance = .Dark
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Default, handler: nil)
        
        titlePrompt.addAction(cancelAction)
        
        titlePrompt.addAction(UIAlertAction(title: "Redefinir", style: .Destructive, handler: { (action) -> Void in
            if let textField = titleTextField {
                self.resetPassword(textField.text!)
            }
        }))
        
        self.presentViewController(titlePrompt, animated: true, completion: nil)
    }
    
    /**
     Make the action of reset password
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    func resetPassword(email : String) {
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let email = email.lowercaseString
        // remove any whitespaces before and after the email address
        let emailClean = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if email.isEmail() == false {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.displayAlert("Oops :(", messageAlert: "Isso não é um email válido")
        } else {
            PFUser.requestPasswordResetForEmailInBackground(emailClean) { (success, error) -> Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if (error == nil) {
                    let success = UIAlertController(title: "Feito :)", message: "Confira no seu email um link para redefinição da senha", preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    success.addAction(okButton)
                    self.presentViewController(success, animated: false, completion: nil)
                    
                } else {
                    let errormessage = self.getError((error?.code)!)
                    let error = UIAlertController(title: "Oops :(", message: errormessage as String, preferredStyle: .Alert)
                    let okButton = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    error.addAction(okButton)
                    self.presentViewController(error, animated: false, completion: nil)
                }
            }
        }
        
    }

}
