//
//  ChangePasswordViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/24/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var newPassword: MKTextField!
    @IBOutlet weak var confirmNewPassword: MKTextField!
    
    let user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeBack:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)

        self.title = "Alterar Senha"
        addLeftNavItemOnView()
        let saveButton : UIBarButtonItem = UIBarButtonItem(title: "Salvar", style: UIBarButtonItemStyle.Plain, target: self, action: "changePassword")
        
        self.navigationItem.rightBarButtonItem = saveButton
        
        let placeholderNewPassword = NSAttributedString(string: "Nova Senha", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let placeholderConfirmNewPassword = NSAttributedString(string: "Confirmar Nova Senha", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        
        // No border, no shadow, floatingPlaceholderEnabled
        self.newPassword.layer.borderColor = UIColor.clearColor().CGColor
        self.newPassword.floatingPlaceholderEnabled = true
        self.newPassword.placeholder = "Nova Senha"
        self.newPassword.attributedPlaceholder = placeholderNewPassword
        self.newPassword.tintColor = UIColor.grayColor()
        self.newPassword.rippleLocation = .Right
        self.newPassword.cornerRadius = 0
        self.newPassword.bottomBorderEnabled = true
        
        self.confirmNewPassword.layer.borderColor = UIColor.clearColor().CGColor
        self.confirmNewPassword.floatingPlaceholderEnabled = true
        self.confirmNewPassword.placeholder = "Confirmar Nova Senha"
        self.confirmNewPassword.attributedPlaceholder = placeholderConfirmNewPassword
        self.confirmNewPassword.tintColor = UIColor.grayColor()
        self.confirmNewPassword.rippleLocation = .Right
        self.confirmNewPassword.cornerRadius = 0
        self.confirmNewPassword.bottomBorderEnabled = true
    }

    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        if textField == self.newPassword {
            self.confirmNewPassword.becomeFirstResponder()
        }
        
        return true
        
    }
    
    /**
     Set a new password for the current user
     - returns: Void
     */
    
    func changePassword() {
        
        self.newPassword.text = newPassword.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.confirmNewPassword.text = confirmNewPassword.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        if self.newPassword.text == "" || self.confirmNewPassword.text == "" {
            self.displayAlert("Oops :(", messageAlert: "Você não pode deixar nenhum campo em branco!")
        } else if self.newPassword.text != self.confirmNewPassword.text {
            self.displayAlert("Oops :(", messageAlert: "As senhas não coincidem!")
        } else {
            user!.password = self.newPassword.text
            user!.saveInBackground()
            self.displayAlert("Feito :)", messageAlert: "Sua senha foi atualizada!")

        }
        
    }

}
