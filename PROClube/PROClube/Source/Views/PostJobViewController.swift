//
//  PostJobViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/31/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

class PostJobViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var jobName: MKTextField!
    @IBOutlet weak var companyName: MKTextField!
    @IBOutlet weak var companyLocalization: MKTextField!
    @IBOutlet weak var companyEmail: MKTextField!
    @IBOutlet weak var jobCategory: MKTextField!
    @IBOutlet weak var jobPayment: MKTextField!
    @IBOutlet weak var jobDescription: UITextView!
    
    var jobType = String()
    var postType = String()
    var charsLeft = String()
    var phone = String()
    var jobDescriptionString = String()
    var gradePickerPayment = UIPickerView()
    var gradePickerCategories = UIPickerView()
    var activityIndicator = MaterialActivityIndicatorView(style: .Large)
    var location: PFGeoPoint?
    var existingJob: PFObject?
    
    let user = PFUser.currentUser()
    let maxtext = 500
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    let jobPaymentValues = ["Pagamento a Combinar", "Até R$ 100,00", "Até R$ 500,00", "Até R$ 1.000,00", "Até R$ 2.000,00", "Até R$ 3.000,00", "Até R$ 5.000,00", "Até R$ 10.000,00", "+ de 10.000,00"]
    var jobCategoriesValues = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showMenu:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.title = "\(self.postType) Vaga \(self.jobType)"
        
        self.addMenuNavItemOnView()
        self.addDoneButton()
        self.fillJobCategoriesValues()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground({
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                self.location = geoPoint
            }
        })
        
        self.gradePickerPayment = UIPickerView()
        self.gradePickerPayment.dataSource = self
        self.gradePickerPayment.delegate = self
        self.gradePickerCategories = UIPickerView()
        self.gradePickerCategories.dataSource = self
        self.gradePickerCategories.delegate = self
        self.jobPayment.inputView = self.gradePickerPayment
        self.jobPayment.text = self.jobPaymentValues[0]
        self.jobPayment.textAlignment = .Center
        self.jobPayment.layer.borderColor = UIColor.MKColor.Green.CGColor
        self.jobPayment.layer.borderWidth = 3
        self.jobPayment.textColor = UIColor.MKColor.Green
        self.jobCategory.inputView = self.gradePickerCategories
        self.jobCategory.text = self.jobCategoriesValues[0]
        self.jobCategory.textAlignment = .Center
        self.jobCategory.layer.borderColor = UIColor.MKColor.BlueGrey.CGColor
        self.jobCategory.layer.borderWidth = 3
        self.jobCategory.textColor = UIColor.MKColor.BlueGrey
        self.jobDescription.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        // setting design of textFields
        
        let placeholderJobName = NSAttributedString(string: "Função a Desempenhar", attributes: [NSForegroundColorAttributeName: UIColor.grayColor()])
        var placeholderCompany = NSAttributedString()
        
        var initialAlertTitle = ""
        var initialAlertDescription = ""
        
        if self.postType == "Oferecer" {
            if self.jobType == "Freela" {
                initialAlertTitle = "Contratar Freelancer"
                initialAlertDescription = "Quer contratar um freelancer? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Emprego" {
                initialAlertTitle = "Oferecer Vaga de Emprego"
                initialAlertDescription = "Possui uma vaga de emprego? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Estágio" {
                initialAlertTitle = "Oferecer Vaga de Estágio"
                initialAlertDescription = "Possui uma vaga de estágio? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Serviço Particular" {
                initialAlertTitle = "Contratar Serviço Particular"
                initialAlertDescription = "Quer contratar algum serviço particular (Professor particular, manicure, encanador, etc) ?, preencha os campos com as informações necessárias e clique em 'Postar'"
            }
            
            self.displayAlert(initialAlertTitle, messageAlert: initialAlertDescription)
            placeholderCompany = NSAttributedString(string: "Empresa ou Contratante", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
            self.companyName.placeholder = "Empresa ou Contratante"
            self.jobDescriptionString = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR\n\nEste é o local para atrair quem vai ocupar este trabalho, escreva sobre o seu projeto ou sua empresa, os requisitos necessários, benefícios oferecidos, etc...\n\nUtilize as palavras chave 'Descrição' e 'Requisitos' para uma boa formatação do conteúdo."
        } else {
            if self.jobType == "Freela" {
                initialAlertTitle = "Procurar Vaga como Freelancer"
                initialAlertDescription = "Quer trabalhar como um freelancer? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Emprego" {
                initialAlertTitle = "Procurar Vaga de Emprego"
                initialAlertDescription = "Procura uma vaga de emprego? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Estágio" {
                initialAlertTitle = "Procurar Vaga de Estágio"
                initialAlertDescription = "Procura uma vaga de estágio? Preencha os campos com as informações necessárias e clique em 'Postar'"
            } else if self.jobType == "Serviço Particular" {
                initialAlertTitle = "Oferecer Serviço Particular"
                initialAlertDescription = "Quer oferecer algum serviço particular (Dar aulas particulares, serviço de manicure, consertar um encanamento, trocar uma lâmpada, etc...) ? Preencha os campos com as informações necessárias e clique em 'Postar'"
            }
            
            if self.existingJob == nil {
                self.displayAlert(initialAlertTitle, messageAlert: initialAlertDescription)
            }
            
            placeholderCompany = NSAttributedString(string: "Seu Nome", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
            self.companyName.placeholder = "Seu Nome"
            self.companyName.text = self.user!["name"] as? String
            self.jobDescriptionString = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR\n\nEste é o local para atrair olhares sobre suas habilidades, preenhca informações como: o que você faz, os serviços que oferece, suas qualificações, sua formação acadêmica, suas experiências profissionais, quais idiomas você domina, etc...\n\nUtilize as palavras chave 'Descrição' e 'Requisitos' para uma boa formatação do conteúdo."
        }
        
        let placeholderCompanyLocalization = NSAttributedString(string: "Localização", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        let placeholderCompanyEmail = NSAttributedString(string: "E-mail", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        
        self.jobName.layer.borderColor = UIColor.clearColor().CGColor
        self.jobName.floatingPlaceholderEnabled = true
        self.jobName.placeholder = "Função a Desempenhar"
        self.jobName.attributedPlaceholder = placeholderJobName
        self.jobName.tintColor = UIColor.grayColor()
        self.jobName.rippleLocation = .Right
        self.jobName.cornerRadius = 0
        self.jobName.bottomBorderEnabled = true
        self.jobName.delegate = self
        
        self.companyName.layer.borderColor = UIColor.clearColor().CGColor
        self.companyName.floatingPlaceholderEnabled = true
        self.companyName.attributedPlaceholder = placeholderCompany
        self.companyName.tintColor = UIColor.grayColor()
        self.companyName.rippleLocation = .Right
        self.companyName.cornerRadius = 0
        self.companyName.bottomBorderEnabled = true
        self.companyName.delegate = self
        
        self.companyLocalization.layer.borderColor = UIColor.clearColor().CGColor
        self.companyLocalization.floatingPlaceholderEnabled = true
        self.companyLocalization.placeholder = "Localização"
        self.companyLocalization.attributedPlaceholder = placeholderCompanyLocalization
        self.companyLocalization.tintColor = UIColor.grayColor()
        self.companyLocalization.rippleLocation = .Right
        self.companyLocalization.cornerRadius = 0
        self.companyLocalization.bottomBorderEnabled = true
        self.companyLocalization.delegate = self
        
        self.companyEmail.layer.borderColor = UIColor.clearColor().CGColor
        self.companyEmail.floatingPlaceholderEnabled = true
        self.companyEmail.placeholder = "E-mail"
        self.companyEmail.attributedPlaceholder = placeholderCompanyEmail
        self.companyEmail.tintColor = UIColor.grayColor()
        self.companyEmail.rippleLocation = .Right
        self.companyEmail.cornerRadius = 0
        self.companyEmail.bottomBorderEnabled = true
        self.companyEmail.text = user?.objectForKey("email") as? String
        self.companyEmail.delegate = self
        
        self.jobDescription.layer.borderColor = UIColor.clearColor().CGColor
        self.jobDescription.tintColor = UIColor.grayColor()
        self.jobDescription.layer.borderColor = UIColor.MKColor.Orange.CGColor
        self.jobDescription.layer.borderWidth = 3
        self.jobDescription.delegate = self
        
        let stringToColor = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR"
        let range = (self.jobDescriptionString as NSString).rangeOfString(stringToColor)
        let attributedString = NSMutableAttributedString(string:self.jobDescriptionString)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.MKColor.DeepOrange, range: range)
        
        if self.jobDescription.text == "" {
            self.jobDescription.attributedText = attributedString
        }
        
        var titleNavigationBar = "Postar"
        
        if self.existingJob != nil {
            if self.existingJob!["offering"] as! Bool == true {
                self.title = "Oferecer Vaga \(self.existingJob!["type"]!)"
            } else {
                self.title = "Procurar Vaga \(self.existingJob!["type"]!)"
            }
            self.jobName.text = self.existingJob!["name"] as? String
            self.companyName.text = self.existingJob!["companyName"] as? String
            self.companyLocalization.text = self.existingJob!["locationString"] as? String
            self.companyEmail.text = self.existingJob!["companyEmail"] as? String
            self.jobCategory.text = self.existingJob!["category"] as? String
            self.jobPayment.text = self.existingJob!["payment"] as? String
            self.jobDescription.text = self.existingJob!["description"] as? String
            titleNavigationBar = "Atualizar"
        }
        
        let postButton : UIBarButtonItem = UIBarButtonItem(title: titleNavigationBar, style: UIBarButtonItemStyle.Plain, target: self, action: "postJob")
        self.navigationItem.rightBarButtonItem = postButton
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        if Device.IS_3_5_INCHES() {
            var frame: CGRect = self.jobDescription.frame
            frame.size.height = 120
            self.jobDescription.frame = frame
            self.jobDescription.reloadInputViews()
            let scrollViewBounds = scrollView.bounds
            var scrollViewInsets = UIEdgeInsetsZero
            
            scrollViewInsets.bottom = scrollViewBounds.size.height
            scrollViewInsets.bottom -= contentView.bounds.size.height - 70
            
            scrollView.contentInset = scrollViewInsets
            scrollView.contentMode = .Top
        }
    }
    
    override func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.contentView.endEditing(true)
        
        if textField == self.jobName {
            self.companyName.becomeFirstResponder()
        } else if textField == self.companyName {
            self.companyLocalization.becomeFirstResponder()
        } else if textField == self.companyLocalization {
            self.companyEmail.becomeFirstResponder()
        }
        
        return true
        
    }
    
    override func textFieldDidBeginEditing(textField: UITextField) {
        
        let myScreenRect: CGRect = self.contentView.bounds
        let keyboardHeight : CGFloat = 252
        
        UIView.beginAnimations("animateView", context: nil)
        var needToMove: CGFloat = 0
        
        var frame : CGRect = self.contentView.frame
        if (textField.frame.origin.y + textField.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height > (myScreenRect.size.height - keyboardHeight)) {
            needToMove = (textField.frame.origin.y + textField.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height) - (myScreenRect.size.height - keyboardHeight);
        }
        
        frame.origin.y = -needToMove
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    override func textFieldDidEndEditing(textField: UITextField) {
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.contentView.frame
        frame.origin.y = 0
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        self.title = "\(self.maxtext - textView.text.characters.count)"
        
        if self.jobDescription.text == self.jobDescriptionString {
            self.jobDescription.text = ""
            self.title = "\(self.maxtext)"
        }
        
        let myScreenRect: CGRect = contentView.bounds
        var keyboardHeight : CGFloat = 206
        
        if Device.IS_3_5_INCHES() {
            keyboardHeight = 276
        } else if Device.IS_4_INCHES() {
            keyboardHeight = 266
        } else if Device.IS_4_7_INCHES() {
            keyboardHeight = 266
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
        
        self.title = "\(self.postType) Vaga \(self.jobType)"
        
        if self.existingJob != nil {
            if self.existingJob!["offering"] as! Bool == true {
                self.title = "Oferecer Vaga \(self.existingJob!["type"]!)"
            } else {
                self.title = "Procurar Vaga \(self.existingJob!["type"]!)"
            }
        }
        
        let stringToColor = "DESCRIÇÃO, CLIQUE AQUI PARA EDITAR"
        let range = (self.jobDescriptionString as NSString).rangeOfString(stringToColor)
        let attributedString = NSMutableAttributedString(string:self.jobDescriptionString)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.MKColor.DeepOrange, range: range)
        
        if self.jobDescription.text == "" {
            self.jobDescription.attributedText = attributedString
        }
        
        UIView.beginAnimations("animateView", context: nil)
        var frame : CGRect = self.contentView.frame
        frame.origin.y = 0
        self.contentView.frame = frame
        UIView.commitAnimations()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.title = "\(self.maxtext - textView.text.characters.count)"
        return textView.text.characters.count + (text.characters.count - range.length) <= self.maxtext
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView.inputView == self.gradePickerPayment {
            return self.jobPaymentValues.count
        } else {
            return self.jobCategoriesValues.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.inputView == self.gradePickerPayment {
            return self.jobPaymentValues[row]
        } else {
            return self.jobCategoriesValues[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        if pickerView.inputView == self.gradePickerPayment {
            self.jobPayment.text = self.jobPaymentValues[row]
        } else {
            self.jobCategory.text = self.jobCategoriesValues[row]
        }
        
        self.view.endEditing(true)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    /**
     Make a query to fill self.jobCategoriesValues
     - returns: Void
     */
    
    func fillJobCategoriesValues() {
        let querySkills = PFQuery(className: "Skill")
        querySkills.limit = 1000
        querySkills.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.jobCategoriesValues.append(object["name"] as! String)
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            self.jobCategoriesValues.sortInPlace()
        })
    }
    
    /**
     Save the post on database
     - returns: Void
     */
    
    func postJob() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Telefone/Celular/WhatsApp", message: "Adicione seu Telefone/Celular ou WhatsApp para facilitar a negociação com os interessados no trabalho.\n\nEste item é opcional, deixe-o em branco se não quiser divulgar seu número", preferredStyle: .Alert)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in }
        actionSheetController.addAction(cancelAction)
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            textField.keyboardAppearance = .Dark
            textField.keyboardType = .NumberPad
            textField.text = (self.user!["phone"] == nil) ? "" : self.user!["phone"] as! String
            let suggestAction: UIAlertAction = UIAlertAction(title: "Enviar", style: .Default) { action -> Void in
                
                textField.text = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if textField.text != "" {
                    self.phone = textField.text!
                } else {
                    self.phone = ""
                }
                
                self.activityIndicator.center = self.view.center
                self.view.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
                UIApplication.sharedApplication().beginIgnoringInteractionEvents()
                
                self.jobName.text = self.jobName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                self.companyName.text = self.companyName.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                self.companyLocalization.text = self.companyLocalization.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                self.jobDescription.text = self.jobDescription.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if self.existingJob != nil {
                    if self.existingJob!["offering"] as! Bool == true {
                        self.postType = "Oferecer"
                    } else {
                        self.postType = "Procurar"
                    }
                }
                
                if ((self.postType == "Oferecer") && (self.jobDescription.text == "" || self.jobDescription.text == self.jobDescriptionString)) {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Oops :(", messageAlert: "Preencha o campo descrevendo o trabalho, não se esqueça dos requisitos e benefícios para ocupá-lo")
                } else if (self.postType == "Procurar" && (self.jobDescription.text == "" || self.jobDescription.text == self.jobDescriptionString)) {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Oops :(", messageAlert: "Preencha o campo descrevendo o que você faz")
                } else if self.jobName.text == "" || self.companyName.text == "" {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Oops :(", messageAlert: "Não deixe nenhum campo em branco!")
                } else if self.jobCategory.text == "" {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.removeFromSuperview()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Oops :(", messageAlert: "Escolha uma categoria relacionada a esse \(self.jobType)")
                } else {
                    
                    print("\n\n\(self.phone)\n\n")
                    let permission = PFACL()
                    permission.publicReadAccess = true
                    permission.publicWriteAccess = true
                    
                    if self.existingJob != nil {
                        self.existingJob!["name"] = self.jobName.text
                        self.existingJob!["description"] = self.jobDescription.text
                        self.existingJob!["companyName"] = self.companyName.text
                        self.existingJob!["companyEmail"] = self.companyEmail.text
                        self.existingJob!["companyPhone"] = self.phone
                        self.existingJob!["category"] = self.jobCategory.text
                        self.existingJob!["location"] = self.location
                        self.existingJob!["locationString"] = self.companyLocalization.text
                        self.existingJob!["payment"] = self.jobPayment.text
                        self.existingJob!["interested"] = []
                        self.existingJob!.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            if (success) {
                                if self.existingJob!["offering"] as! Bool == true {
                                    self.postType = "oferta"
                                } else {
                                    self.postType = "procura"
                                }
                                self.displayAlert("Feito :)", messageAlert: "Sua \(self.postType) por \(self.existingJob!["type"]!) foi atualizada! Você será notificado quando alguém marcá-la como favorito")
                            } else {
                                self.displayAlert("Oops :(", messageAlert: "Houve um erro ao postar seu \(self.existingJob!["type"]!), tente novamente mais tarde")
                            }
                        }
                    } else {
                        let newJob = PFObject(className:"Job")
                        newJob["name"] = self.jobName.text
                        newJob["description"] = self.jobDescription.text
                        newJob["companyName"] = self.companyName.text
                        newJob["companyEmail"] = self.companyEmail.text
                        newJob["companyPhone"] = self.phone
                        newJob["category"] = self.jobCategory.text
                        newJob["location"] = self.location
                        newJob["locationString"] = self.companyLocalization.text
                        newJob["payment"] = self.jobPayment.text
                        newJob["type"] = self.jobType
                        newJob["interested"] = []
                        newJob["owner"] = self.user?.objectId
                        
                        if self.postType == "Oferecer" {
                            newJob["offering"] = true
                        } else {
                            newJob["offering"] = false
                        }
                        
                        newJob.ACL = permission
                        newJob.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.removeFromSuperview()
                            UIApplication.sharedApplication().endIgnoringInteractionEvents()
                            if (success) {
                                if self.postType == "Oferecer" {
                                    self.postType = "oferta"
                                } else if self.postType == "Procurar" {
                                    self.postType = "procura"
                                }
                                self.displayAlert("Feito :)", messageAlert: "Sua \(self.postType) por \(self.jobType) foi postada! Você será notificado quando alguém marcá-la como favorito")
                            } else {
                                self.displayAlert("Oops :(", messageAlert: "Houve um erro ao postar seu \(self.jobType), tente novamente mais tarde")
                            }
                        }
                    }
                }
            }
            
            actionSheetController.addAction(suggestAction)
        }
            
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    /**
     Add a "Done" button on keyboard
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
        self.jobName.inputAccessoryView = keyboardToolbar
        self.companyName.inputAccessoryView = keyboardToolbar
        self.companyLocalization.inputAccessoryView = keyboardToolbar
        self.companyEmail.inputAccessoryView = keyboardToolbar
        self.jobCategory.inputAccessoryView = keyboardToolbar
        self.jobPayment.inputAccessoryView = keyboardToolbar
        self.jobDescription.inputAccessoryView = keyboardToolbar
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                print("Error:" + error!.localizedDescription)
                return
            }

            if placemarks!.count > 0 {
                self.locationManager.stopUpdatingLocation()
                let pm = placemarks![0] as CLPlacemark
                self.companyLocalization.text = pm.locality! + "/" + pm.administrativeArea!
            } else {
                print("Error with data")
            }
  
        })
    
    }
    
}
