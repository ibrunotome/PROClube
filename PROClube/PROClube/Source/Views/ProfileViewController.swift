//
//  ProfileViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/24/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import Parse

class ProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var username: MKTextField!
    @IBOutlet weak var name: MKTextField!
    @IBOutlet weak var email: MKTextField!
    @IBOutlet weak var phone: MKTextField!
    @IBOutlet weak var bio: UITextView!
    
    let user = PFUser.currentUser()
    let maxtext = 500
    let imagePicker = UIImagePickerController()
    var activityIndicator: MaterialActivityIndicatorView!
    var location: PFGeoPoint?
    var bioText = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR\n\nEste é o local para atrair olhares sobre suas habilidades, escreva sobre você e o que faz, suas qualificações, sua formação acadêmica, suas experiências profissionais e quais idiomas você domina, etc..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.title = "Editar Perfil"
        addLeftNavItemOnView()
        addDoneButton()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground({
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.location = geoPoint
            }
        })
        
        let saveButton : UIBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: "saveProfile")
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        self.imagePicker.delegate = self
        self.profilePicture.contentMode = .ScaleAspectFill
        
        let currentUserPicture = (user!.objectForKey("profilePicture") as! PFFile)
        
        currentUserPicture.getDataInBackgroundWithBlock({
            (imageData: NSData?, error: NSError?) -> Void in
            
            if imageData != nil {
                if let imageData = imageData where error == nil {
                    
                    let image = UIImage(data:imageData)?.correctlyOrientedImage()
                    self.profilePicture.image = image
                    
                }
            } else {
                self.profilePicture.image = UIImage(named: "grayCamera.png")
            }
        })
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 3.0;
        self.profilePicture.layer.borderColor = UIColor.grayColor().CGColor
        
        // setting design of textFields
        
        let placeholdername = NSAttributedString(string: "Nome", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let placeholderUsername = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let placeholderEmail = NSAttributedString(string: "E-mail", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let placeholderPhone = NSAttributedString(string: "Telefone (Opcional)", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        
        self.name.layer.borderColor = UIColor.clearColor().CGColor
        self.name.floatingPlaceholderEnabled = true
        self.name.placeholder = "Nome"
        self.name.text = user!.objectForKey("name") as? String
        self.name.attributedPlaceholder = placeholdername
        self.name.tintColor = UIColor.grayColor()
        self.name.rippleLocation = .Right
        self.name.cornerRadius = 0
        self.name.bottomBorderEnabled = true
        self.name.delegate = self
        
        self.username.layer.borderColor = UIColor.clearColor().CGColor
        self.username.floatingPlaceholderEnabled = true
        self.username.placeholder = "Username"
        self.username.text = user!.objectForKey("username") as? String
        self.username.attributedPlaceholder = placeholderUsername
        self.username.tintColor = UIColor.grayColor()
        self.username.rippleLocation = .Right
        self.username.cornerRadius = 0
        self.username.bottomBorderEnabled = true
        self.username.delegate = self
        
        self.email.layer.borderColor = UIColor.clearColor().CGColor
        self.email.floatingPlaceholderEnabled = true
        self.email.placeholder = "E-mail"
        self.email.text = user?.objectForKey("email") as? String
        self.email.attributedPlaceholder = placeholderEmail
        self.email.tintColor = UIColor.grayColor()
        self.email.rippleLocation = .Right
        self.email.cornerRadius = 0
        self.email.bottomBorderEnabled = true
        self.email.delegate = self
        
        self.phone.layer.borderColor = UIColor.clearColor().CGColor
        self.phone.floatingPlaceholderEnabled = true
        self.phone.placeholder = "Telefone (Opcional)"
        self.phone.text = user?.objectForKey("phone") as? String
        self.phone.attributedPlaceholder = placeholderPhone
        self.phone.tintColor = UIColor.grayColor()
        self.phone.rippleLocation = .Right
        self.phone.cornerRadius = 0
        self.phone.bottomBorderEnabled = true
        self.phone.delegate = self
        
        let stringToColor = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR"
        let range = (self.bioText as NSString).rangeOfString(stringToColor)
        let attributedString = NSMutableAttributedString(string:self.bioText)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.MKColor.DeepOrange, range: range)
        self.bio.layer.borderColor = UIColor.clearColor().CGColor
        if self.user?.objectForKey("bio") as? String == "" {
            self.bio.attributedText = attributedString
        } else {
            self.bio.text = self.user!.objectForKey("bio") as? String
        }
        self.bio.font = UIFont.systemFontOfSize(15.0)
        self.bio.tintColor = UIColor.grayColor()
        self.bio.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if Device.IS_3_5_INCHES() {
            let scrollViewBounds = scrollView.bounds
            var scrollViewInsets = UIEdgeInsetsZero
            
            scrollViewInsets.bottom = scrollViewBounds.size.height
            scrollViewInsets.bottom -= contentView.bounds.size.height - 40
            
            scrollView.contentInset = scrollViewInsets
            scrollView.contentMode = .Top
        }
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.contentView.endEditing(true)
        
        if textField == self.name {
            self.username.becomeFirstResponder()
        } else if textField == self.username {
            self.email.becomeFirstResponder()
        } else if textField == self.email {
            self.phone.becomeFirstResponder()
        } else if textField == self.phone {
            self.bio.becomeFirstResponder()
        }
        
        return true
        
    }
    
    override func textFieldDidBeginEditing(textField: UITextField) { // became first responder
        
        //move textfields up
        let myScreenRect: CGRect = contentView.bounds
        let keyboardHeight : CGFloat = 252
        
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
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        self.title = "\(maxtext - textView.text.characters.count)"
        
        if self.bio.text == self.bioText {
            self.bio.text = ""
            self.title = "\(self.maxtext)"
        }
        
        let myScreenRect: CGRect = contentView.bounds
        var keyboardHeight : CGFloat = 206
        
        if Device.IS_3_5_INCHES() {
            keyboardHeight = 106
        } else {
            keyboardHeight = 206
        }
        
        UIView.beginAnimations("animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.contentView.frame
        if (textView.frame.origin.y + textView.frame.size.height + /*self.navigationController.navigationBar.frame.size.height + */UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textView.frame.origin.y + textView.frame.size.height + /*self.navigationController.navigationBar.frame.size.height +*/ UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        
        frame.origin.y = -needToMove
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        self.title = "Editar Perfil"
        
        let stringToColor = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR"
        let range = (self.bioText as NSString).rangeOfString(stringToColor)
        let attributedString = NSMutableAttributedString(string:self.bioText)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.MKColor.DeepOrange, range: range)
        
        if self.bio.text == "" {
            self.bio.attributedText = attributedString
            self.bio.font = UIFont.systemFontOfSize(15.0)
        }
        
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.contentView.frame
        frame.origin.y = 0
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    /**
     Choose a profile picture from camera or camera roll
     - parameter sender: AnyObject
     - returns: Void
     */
    
    @IBAction func chooseProfilePicture(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Imagem de Perfil", message: nil, preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
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
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Minhas Fotos", style: .Default) { action -> Void in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profilePicture.contentMode = .ScaleAspectFill
            self.profilePicture.image = pickedImage.correctlyOrientedImage()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     Update user profile
     - returns: Void
     */
    
    func saveProfile() {
        
        if self.bio.text == self.bioText {
            self.bio.text = ""
        }
        
        self.name.text = self.name.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.username.text = self.username.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.email.text = self.email.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.bio.text = self.bio.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if (self.email.text?.isEmail() == false) {
            self.displayAlert("Oops :(", messageAlert: "Isso não é um email")
        } else if self.name.text != "" && self.username.text != "" && self.email.text != "" {
            self.activityIndicator = MaterialActivityIndicatorView(style: .Large)
            self.activityIndicator.center = self.view.center
            self.view.addSubview(activityIndicator)
            self.activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            self.user!["name"] = self.name.text
            self.user!["username"] = self.username.text?.lowercaseString
            self.user!["email"] = self.email.text?.lowercaseString
            self.user!["phone"] = self.phone.text
            self.user!["bio"] = self.bio.text
            self.user!["location"] = self.location
            let imageData = UIImagePNGRepresentation(self.resizeImage(self.profilePicture.image!, newSize: CGSize(width: 108, height: 108)))
            let imageFile: PFFile = PFFile(data: imageData!)!
            self.user!.setObject(imageFile, forKey: "profilePicture")
            self.user!.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if (success) {
                    self.displayAlert("Feito :)", messageAlert: "Seus dados foram atualizados!")
                } else {
                    self.displayAlert("Oops :(", messageAlert: "\(self.getError((error?.code)!))")
                }
            }
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            self.displayAlert("Oops :(", messageAlert: "Você não pode deixar nenhum dos 3 primeiros campos em branco!")
        }
    }
    
    /**
     Add a "Done" button to keyboard
     - returns: Void
     */
    
    func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.barStyle = .BlackTranslucent
        keyboardToolbar.tintColor = UIColor.whiteColor()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
            target: view, action: Selector("endEditing:"))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.name.inputAccessoryView = keyboardToolbar
        self.username.inputAccessoryView = keyboardToolbar
        self.email.inputAccessoryView = keyboardToolbar
        self.phone.inputAccessoryView = keyboardToolbar
        self.bio.inputAccessoryView = keyboardToolbar
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.title = "\(self.maxtext - textView.text.characters.count)"
        return textView.text.characters.count + (text.characters.count - range.length) <= self.maxtext
    }
}
