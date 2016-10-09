//
//  SignUpViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/13/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var name: MKTextField!
    @IBOutlet weak var email: MKTextField!
    @IBOutlet weak var username: MKTextField!
    @IBOutlet weak var password: MKTextField!
    
    /// Controller of background movie
    let moviePlayerController = AVPlayerViewController()
    /// The user location in the moment of use
    var location: PFGeoPoint?
    /// imagePicker for take profile picture
    let imagePicker = UIImagePickerController()
    /// Loading activity indicator
    var activityIndicator: MaterialActivityIndicatorView!
    /// Player of background movie
    var aPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground({
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.location = geoPoint
            }
        })
        
        self.imagePicker.delegate = self
        self.profilePicture.image = UIImage(named: "camera.png")
        self.profilePicture.contentMode = .ScaleAspectFill
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.translucent = true
        
        /// Looks for single tap for dismiss keyboard.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
        self.playBackgroundMovie()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didPlayToEndTime", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 3.0;
        self.profilePicture.layer.borderColor = UIColor.whiteColor().CGColor
        self.profilePicture.image = self.profilePicture.image?.correctlyOrientedImage()
        
        // setting design of textFields
        let placeholdername = NSAttributedString(string: "Nome", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        let placeholderEmail = NSAttributedString(string: "E-mail", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        let placeholderUsername = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        let placeholderPassword = NSAttributedString(string: "Senha", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor()])
        
        self.name.layer.borderColor = UIColor.clearColor().CGColor
        self.name.floatingPlaceholderEnabled = true
        self.name.placeholder = "Nome"
        self.name.attributedPlaceholder = placeholdername
        self.name.tintColor = UIColor.whiteColor()
        self.name.rippleLocation = .Right
        self.name.cornerRadius = 0
        self.name.bottomBorderEnabled = true
        self.name.delegate = self
        
        self.email.layer.borderColor = UIColor.clearColor().CGColor
        self.email.floatingPlaceholderEnabled = true
        self.email.placeholder = "E-mail"
        self.email.attributedPlaceholder = placeholderEmail
        self.email.tintColor = UIColor.whiteColor()
        self.email.rippleLocation = .Right
        self.email.cornerRadius = 0
        self.email.bottomBorderEnabled = true
        self.email.delegate = self
        
        self.username.layer.borderColor = UIColor.clearColor().CGColor
        self.username.floatingPlaceholderEnabled = true
        self.username.placeholder = "Username"
        self.username.attributedPlaceholder = placeholderUsername
        self.username.tintColor = UIColor.whiteColor()
        self.username.rippleLocation = .Right
        self.username.cornerRadius = 0
        self.username.bottomBorderEnabled = true
        self.username.delegate = self
        
        self.password.layer.borderColor = UIColor.clearColor().CGColor
        self.password.floatingPlaceholderEnabled = true
        self.password.placeholder = "Senha"
        self.password.attributedPlaceholder = placeholderPassword
        self.password.tintColor = UIColor.whiteColor()
        self.password.rippleLocation = .Right
        self.password.cornerRadius = 0
        self.password.bottomBorderEnabled = true
        self.password.delegate = self
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLayoutSubviews() {
        
        if Device.IS_3_5_INCHES() {
            let scrollViewBounds = scrollView.bounds
            var scrollViewInsets = UIEdgeInsetsZero
            
            scrollViewInsets.bottom = scrollViewBounds.size.height
            scrollViewInsets.bottom -= contentView.bounds.size.height - 50
            
            scrollView.contentInset = scrollViewInsets
            scrollView.contentMode = .Top
        }
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.contentView.endEditing(true)
        
        if textField == self.name {
            self.email.becomeFirstResponder()
        } else if textField == self.email {
            self.username.becomeFirstResponder()
        } else if textField == self.username {
            self.password.becomeFirstResponder()
        }
        
        return true
        
    }
    
    override func textFieldDidBeginEditing(textField: UITextField) { // became first responder
        
        //move textfields up
        let myScreenRect: CGRect = contentView.bounds
        let keyboardHeight : CGFloat = 216
        
        UIView.beginAnimations("animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.contentView.frame
        if (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        
        frame.origin.y = -needToMove
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    override func textFieldDidEndEditing(textField: UITextField) {
        //move textfields back down
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.contentView.frame
        frame.origin.y = 0
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilePicture.contentMode = .ScaleAspectFill
            self.profilePicture.image = pickedImage
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Present a view controler to choose profile picture, can be a new photo or come from local data
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func chooseProfilePicture(sender: AnyObject) {
        
        /// Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Imagem de Perfil", message: nil, preferredStyle: .ActionSheet)
        
        /// Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        /// Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Nova Foto", style: .Default) { action -> Void in
            if UIImagePickerController.isSourceTypeAvailable(
                UIImagePickerControllerSourceType.Camera) {
                    
                    self.imagePicker.delegate = self
                    self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                    self.imagePicker.mediaTypes =  NSArray(object: kUTTypeImage) as! [String]
                    self.imagePicker.allowsEditing = true
                    
                    self.presentViewController(self.imagePicker, animated: true,
                        completion: nil)
            }
        }
        actionSheetController.addAction(takePictureAction)
        
        /// Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Minhas Fotos", style: .Default) { action -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        
        // Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    /**
     Send user back to the home Screen
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func backToHomeScreen(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Try do the SignUp action
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    @IBAction func singUp(sender: AnyObject) {
        
        self.name.text = self.name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.username.text = self.username.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.email.text = self.email.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (self.email.text?.isEmail() == false) {
            self.displayAlert("Oops :(", messageAlert: "Isso não é um email")
        } else if self.name.text == "" || self.email.text == "" || self.password.text == "" || self.username.text == "" {
            self.displayAlert("Oops :(", messageAlert: "Você não pode deixar nenhum campo em branco!")
        } else {
            self.activityIndicator = MaterialActivityIndicatorView(style: .Large)
            self.activityIndicator.center = self.view.center
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            let user = PFUser()
            user.username = self.username.text?.lowercaseString
            user.email = self.email.text?.lowercaseString
            user.password = self.password.text
            user["name"] = self.name.text
            user["phone"] = ""
            user["skills"] = []
            user["interested"] = []
            user["bio"] = "Escreva sobre você e o que faz"
            user["location"] = self.location
            
            if (self.profilePicture.image == UIImage(named: "camera.png")) {
                self.profilePicture.image = UIImage(named: "avatar.png")
            }
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if let error = error {
                    self.displayAlert("Oops :(", messageAlert: self.getError(error.code))
                } else {
                    let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
                    currentInstallation["installationUser"] = PFUser.currentUser()!.objectId
                    currentInstallation.saveInBackground()
                    let imageData = UIImagePNGRepresentation(self.resizeImage(self.profilePicture.image!, newSize: CGSize(width: 128, height: 128)))
                    let imageFile: PFFile = PFFile(data: imageData!)!
                    user.setObject(imageFile, forKey: "profilePicture")
                    user.saveInBackground()
                    let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    let leftVC: MenuViewController = UIStoryboard.menuViewController()!
                    tempAppDelegate.window = UIWindow(frame: UIScreen.mainScreen().bounds)
                    tempAppDelegate.window!.backgroundColor = UIColor.whiteColor()
                    tempAppDelegate.window!.makeKeyAndVisible()
                    tempAppDelegate.mainNavigationController = UIStoryboard.mainNavigationController()!
                    tempAppDelegate.lsmVC = LSMViewController(leftVC: leftVC, mainVC: tempAppDelegate.mainNavigationController)
                    tempAppDelegate.window!.rootViewController = tempAppDelegate.lsmVC
                }
            }
        }
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
    
    /// Calls this function when the tap is recognized.
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

}
