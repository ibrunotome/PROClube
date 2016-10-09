//
//  FeedTableViewController.swift
//  PROClube
//
//  Created by Bruno Tomé on 10/30/15.
//  Copyright © 2015 Mobile BR. All rights reserved.
//

import UIKit
import Parse
import MessageUI

class FeedTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, MFMailComposeViewControllerDelegate {
    
    /// The current user
    let user = PFUser.currentUser()
    /// Array of avalaible filters
    let filterValues = ["Todos os Trabalhos", "Apenas Freelas", "Apenas Empregos", "Apenas Estágios", "Apenas Serviço Particular", "Apenas Meus Favoritos", "Apenas Meus Posts", "Semelhante a Mim",  "Pagamento a Combinar", "Até R$ 100,00", "Até R$ 500,00", "Até R$ 1.000,00", "Até R$ 2.000,00", "Até R$ 3.000,00", "Até R$ 5.000,00", "Até R$ 10.000,00", "+ R$ 10.000,00"]
    /// Button of compass
    let compassImage = UIButton()
    /// Search element controller
    let searchController = UISearchController(searchResultsController: nil)
    /// Slider element for choose value of km
    let locationSlider = UISlider()
    /// Label that display current value of km
    let locationLabel = UILabel()
    /// List of jobs that match with the query
    var jobs = [PFObject]()
    /// List of jobs that match with the search term
    var filteredJobs = [PFObject]()
    /// The Parse query for Job
    var queryJobs = PFQuery(className:"Job")
    /// Textfield that will be show the chosen filter
    var filterChoosed = UITextField()
    /// The refresher element
    var refresher = UIRefreshControl()
    /// The filter element
    var gradePicker = UIPickerView()
    /// Type of search, can be offering or searching
    var typeSearch =  "offering"
    /// Text that will be use in filter
    var filterText = "Todos os Trabalhos"
    /// The loading indicator view
    var activityIndicator = MaterialActivityIndicatorView(style: .Large)
    /// Define if will filter by location or not
    var locationStateControl = false
    /// The number of records by page (Constant)
    let stepPage = 24
    /// The number of current page
    var countPage = 0
    /// Maximum limit records of your parse table class
    var maxRow = 0
    /// Guess maximum number of pages
    var maxPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PROClube"
        
        self.addMenuNavItemOnView()
        self.addTutorialNavItemOnView()
        
        // Makes a thread to track app usage and show a UIAlert to
        // user review the app
        let rate = RateMyApp.sharedInstance        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            rate.trackAppUsage()
        })
        
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        /// Frame for display the locationSlider
        let frame: CGRect = tableView.frame
        self.locationSlider.frame = CGRectMake(0, 90, frame.width, 40)
        self.locationSlider.backgroundColor = UIColor.MKColor.BlueGrey
        self.locationSlider.minimumValue = 0
        self.locationSlider.maximumValue = 1000
        self.locationSlider.continuous = false
        self.locationSlider.tintColor = UIColor.MKColor.Orange
        self.locationSlider.value = 50
        self.locationSlider.addTarget(self, action: "locationSliderChange:", forControlEvents: .ValueChanged)
        self.locationSlider.alpha = 0
        self.locationLabel.frame = CGRectMake(0, 130, frame.width, 40)
        self.locationLabel.backgroundColor = UIColor.MKColor.BlueGrey
        self.locationLabel.textColor = UIColor.whiteColor()
        self.locationLabel.textAlignment = .Center
        self.locationLabel.text = "Até \(self.locationSlider.value) km"
        self.locationLabel.alpha = 0
        self.view.addSubview(self.locationSlider)
        self.view.addSubview(self.locationLabel)
        
        self.compassImage.setBackgroundImage(UIImage(named: "compassOff.png"), forState: .Normal)
        
        /// Recognize the long press gesture for activate locationSlider
        let longPressRecognizerLocation = UILongPressGestureRecognizer(target: self, action: "showLocationSlider:")
        self.compassImage.addGestureRecognizer(longPressRecognizerLocation)
        
        /// Recognize the swipe right gesture for call left menu
        let swipeRight : UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showMenu:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        self.searchController.searchBar.barTintColor = UIColor.MKColor.BlueGrey
        self.searchController.searchBar.tintColor = UIColor.whiteColor()
        self.searchController.searchBar.placeholder = "Procurar"
        self.searchController.searchBar.setValue("Cancelar", forKey: "_cancelButtonText")
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.keyboardAppearance = .Dark
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.refresher.backgroundColor = UIColor.whiteColor()
        self.tableView.backgroundColor = UIColor.whiteColor()
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.filterChoosed = UITextField(frame: CGRectMake(10, 0, self.view.frame.width - 20, 50))
        self.filterChoosed.text = self.filterText
        self.addDoneButton()
        self.refresher.attributedTitle = NSAttributedString(string: "Puxe para atualizar")
        self.refresher.addTarget(self, action: "refresherWork:", forControlEvents: UIControlEvents.AllEvents)
        self.tableView?.addSubview(self.refresher)
        self.configureQuery()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.jobs.removeAll()
        self.filteredJobs.removeAll()
        self.refreshData()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let frame: CGRect = tableView.frame
        let filterImage = UIImageView(image: UIImage(named: "filter.png"))
        filterImage.frame = CGRectMake(frame.size.width - 50, 5, 40, 40)
        filterImage.contentMode = .ScaleAspectFill
        
        self.compassImage.frame = CGRectMake(frame.size.width - 100, 5, 40, 40)
        self.compassImage.addTarget(self, action: "toogleLocationBool:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.gradePicker = UIPickerView()
        self.gradePicker.delegate = self
        self.filterChoosed.inputView = self.gradePicker
        self.filterChoosed.textColor = UIColor.whiteColor()
        self.filterChoosed.delegate = self
        
        let headerView: UIView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        headerView.backgroundColor = UIColor.MKColor.BlueGrey
        headerView.addSubview(filterImage)
        headerView.addSubview(self.filterChoosed)
        headerView.addSubview(self.compassImage)

        return headerView
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return self.filteredJobs.count
        } else {
            return self.jobs.count
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.activityIndicator.center = cell.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        let row = indexPath.row
        let lastRow = self.jobs.count - 1
        /// prevision of the page limit based on step and countPage
        let pageLimit = (((self.countPage+1) * (self.stepPage)) - 1)
        // Only for debug
        // print("\(row) from [0,\(lastRow)] -> limit: \(pageLimit)")
        
        // 1) The last rown and is the last
        // 2) To avoid two calls in a short space from time, while the data is downloading
        // 3) The current array count is smaller than the maximum limit from database
        if (row == lastRow) && (row == pageLimit) && (self.jobs.count < self.maxRow) {
            self.countPage++
            // print("Loading Page \(self.countPage) from \(self.maxPage)")
            self.refreshData()
            self.tableView.reloadData()
        }
        
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        /// Define if job will be come from jobs list or filtered jobs list
        let job = (self.searchController.active && self.searchController.searchBar.text != "") ? self.filteredJobs[indexPath.row] : self.jobs[indexPath.row]
        
        let more = UITableViewRowAction(style: .Normal, title: "Outros") { action, index in
            /// Create the AlertController
            let actionSheetController: UIAlertController = UIAlertController(title: "Mais Opções", message: nil, preferredStyle: .ActionSheet)
            
            /// Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            
            /// Create and add first option action
            let editAction: UIAlertAction = UIAlertAction(title: "Editar", style: .Default) { action -> Void in
                let vc: PostJobViewController = UIStoryboard.postJobViewController()!
                vc.existingJob = job
                let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                tempAppDelegate.mainNavigationController.popViewControllerAnimated(false)
                tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
            }
            
            /// Create and add a second option action
            let deleteAction: UIAlertAction = UIAlertAction(title: "Apagar", style: .Destructive) { action -> Void in
                self.confirmDelete(indexPath, row: indexPath.row)
            }
            
            /// Create and add a third option action
            let contactAction: UIAlertAction = UIAlertAction(title: "Entrar em Contato", style: .Default) { action -> Void in
                self.sendEmail(job["companyEmail"] as! String)
            }
            
            /// Create and add a fourth option action
            let seeInterestedAction: UIAlertAction = UIAlertAction(title: "Ver Interessados", style: .Default) { action -> Void in
                let vc: ProfileTableViewController = UIStoryboard.profileTableViewController()!
                vc.peopleInterested = job["interested"]! as! [String]
                let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
            }
            
            actionSheetController.addAction(cancelAction)
            actionSheetController.addAction(contactAction)
            
            if job["owner"] as? String == self.user?.objectId {
                actionSheetController.addAction(seeInterestedAction)
                actionSheetController.addAction(editAction)
                actionSheetController.addAction(deleteAction)
            }
            
            actionSheetController.popoverPresentationController?.sourceView = self.view
            actionSheetController.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
                self.view.bounds.size.height, 1.0, 1.0)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
        
        more.backgroundColor = UIColor.MKColor.Red
        
        var favorite = UITableViewRowAction()
        
        if job["interested"]?.containsObject((self.user?.objectId)!) == true {
            favorite = UITableViewRowAction(style: .Normal, title: "Favorito") { action, index in
                job.removeObject(((self.user?.objectId)! as String), forKey: "interested")
                self.user!.removeObject((job.objectId)!, forKey: "interested")
                self.user!.saveInBackground()
                job.saveInBackground()
                self.tableView.reloadData()
                self.displayAlert("Feito :)", messageAlert: "Você não está mais interessado neste \(job["type"]!)")
            }
            favorite.backgroundColor = UIColor.MKColor.Green
        } else {
            favorite = UITableViewRowAction(style: .Normal, title: "Favoritar") { action, index in
                let query: PFQuery = PFInstallation.query()!
                query.whereKey("installationUser", equalTo: job["owner"]! as! String)
                let data = [
                    "alert" : "\(self.user!["name"]!) se interessou pelo \(job["type"]!) que você postou!",
                    "badge" : "Increment",
                    "sound" : "default"
                ]
                let push = PFPush()
                push.setQuery(query)
                push.setData(data)
                push.sendPushInBackground()
                
                
                job.addUniqueObject(((self.user?.objectId)! as String), forKey: "interested")
                self.user!.addUniqueObject((job.objectId)!, forKey: "interested")
                job.saveInBackground()
                self.user!.saveInBackground()
                self.tableView.reloadData()
                self.displayAlert("Feito :)", messageAlert: "Você está interessado neste \(job["type"]!)")
            }
            favorite.backgroundColor = UIColor.MKColor.Orange
        }
        
        let share = UITableViewRowAction(style: .Normal, title: "Publicar") { action, index in
            var jobType = ""
            if job["offering"] as! Bool == true {
                jobType = "Oferta"
            } else {
                jobType = "Procura"
            }
            let shareString = "\(jobType) de \(job["type"]!) no PROClube.\n\n\(job["companyName"]!)\nLocalização: \(job["locationString"]!)\nContato: \(job["companyEmail"]!)\n\nFunção: \(job["name"]!).\n\nDescrição: \(job["description"]!)"
            let objectsToShare = [shareString]
            let activityViewController = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
            
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
                self.view.bounds.size.height, 1.0, 1.0)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
        share.backgroundColor = UIColor.MKColor.DeepOrange
        
        return [more, share, favorite]
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath) as! FeedTableViewCell
        
        /// Define if job will be come from jobs list or filteredJobs list
        let job = (self.searchController.active && self.searchController.searchBar.text != "") ? self.filteredJobs[indexPath.row] : self.jobs[indexPath.row]
        
        cell.titlePost.text = job["name"]?.uppercaseString
        cell.ownerPost.text = (job["companyName"] as! String) + " - " + (job["locationString"] as! String)
        cell.ownerPost.font = UIFont.systemFontOfSize(12.0)
        cell.descriptionPost.text = job["description"] as? String
        cell.descriptionPost.font = UIFont.systemFontOfSize(14.0)
        let dateCreated = job.createdAt!
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        
        cell.updatedAt.text = (job["offering"] as! Bool == true) ? "Vaga de \(job["type"]!) oferecida em \(NSString(format: "%@", dateFormat.stringFromDate(dateCreated)))" : "Procurando \(job["type"]!) em \(NSString(format: "%@", dateFormat.stringFromDate(dateCreated)))"
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /// Define if job will be come from jobs list or filtereJobs list
        let job = (self.searchController.active && self.searchController.searchBar.text != "") ? self.filteredJobs[indexPath.row] : self.jobs[indexPath.row]
        
        let tempAppDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let vc: FeedDetailViewController = UIStoryboard.feedDetailViewController()!
        vc.title = job["type"] as? String
        vc.job = job
        tempAppDelegate.mainNavigationController!.pushViewController(vc, animated: true)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.filterValues.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.filterValues[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        self.filterChoosed.text = self.filterValues[row]
        self.configureQuery()
        self.view.endEditing(true)
    }
    
    /**
     Call self.refreshData after slider.value be defined
     - parameter sender: term will be searched, of type String
     - returns: Void
     */
    
    func filterContentForSearchText(searchText: String) {
        self.filteredJobs = self.jobs.filter { job in
            return (job["name"] as! String).lowercaseString.containsString(searchText.lowercaseString)
        }
        
        self.tableView.reloadData()
    }
    
    /**
     Call self.refreshData after slider.value be defined
     - parameter sender: of type UISlider
     - returns: Void
     */
    
    func locationSliderChange(sender:UISlider!) {
        let location = self.user!["location"] as! PFGeoPoint
        self.queryJobs.whereKey("location", nearGeoPoint: location, withinKilometers: Double(sender.value))
        self.jobs.removeAll()
        self.filteredJobs.removeAll()
        self.refreshData()
        self.compassImage.setBackgroundImage(UIImage(named: "compassOn.png"), forState: .Normal)
        self.locationStateControl = true
        self.locationLabel.text = "Até \(Int(sender.value)) km"
        self.locationSlider.alpha = 0
        self.locationLabel.alpha = 0
    }
    
    /**
     Show locationSlider and locationLabel on screen
     - parameter sender: of type UILongPressGestureRecognizer
     - returns: Void
     */
    
    func showLocationSlider(sender: UILongPressGestureRecognizer) {
        self.compassImage.setBackgroundImage(UIImage(named: "compassOn.png"), forState: .Normal)
        self.locationStateControl = true
        self.locationSlider.alpha = 1
        self.locationLabel.alpha = 1
    }
    
    /**
     Define if search by location is active or not, and call self.configureQuery
     - parameter sender: of type UIButton
     - returns: Void
     */
    
    func toogleLocationBool(sender: UIButton) {
        if self.locationStateControl == true {
            self.compassImage.setBackgroundImage(UIImage(named: "compassOff.png"), forState: .Normal)
            self.locationStateControl = false
        } else {
            self.compassImage.setBackgroundImage(UIImage(named: "compassOn.png"), forState: .Normal)
            self.locationStateControl = true
        }
        self.jobs.removeAll()
        self.filteredJobs.removeAll()
        self.configureQuery()
    }
    
    /**
     Configure queryJobs and call self.refreshData after clean actual list of jobs
     - returns: Void
     */
    
    func configureQuery() {
        
        self.locationSlider.alpha = 0
        self.locationLabel.alpha = 0
        
        self.queryJobs = PFQuery(className:"Job")
        
        if self.typeSearch == "offering" {
            self.queryJobs.whereKey("offering", equalTo: true)
        } else {
            self.queryJobs.whereKey("offering", equalTo: false)
        }
        
        if self.locationStateControl == true {
            let location = self.user!["location"] as! PFGeoPoint
            self.queryJobs.whereKey("location", nearGeoPoint: location)
        }
        
        switch self.filterChoosed.text! {
        case "Apenas Freelas":
            self.queryJobs.whereKey("type", equalTo: "Freela")
            break
        case "Apenas Empregos":
            self.queryJobs.whereKey("type", equalTo: "Emprego")
            break
        case "Apenas Estágios":
            self.queryJobs.whereKey("type", equalTo: "Estágio")
            break
        case "Apenas Serviço Particular":
            self.queryJobs.whereKey("type", equalTo: "Serviço Particular")
            break
        case "Apenas Meus Favoritos":
            self.queryJobs.whereKey("objectId", containedIn: self.user!["interested"] as! [AnyObject])
            break
        case "Apenas Meus Posts":
            self.queryJobs.whereKey("owner", equalTo: (self.user?.objectId)!)
            break
        case "Semelhante a Mim":
            if self.user!["skills"]?.count == 0 {
                self.displayAlert("Oops!", messageAlert: "Você não definiu nenhuma categoria para o seu perfil, para definir até 5 categorias, vá até o Menu --> Outros --> Opções --> Editar Categorias")
            } else {
                self.queryJobs.whereKey("category", containedIn: self.user!["skills"] as! [AnyObject])
            }
            break
        case "Pagamento a Combinar":
            self.queryJobs.whereKey("payment", equalTo: "Pagamento a Combinar")
            break
        case "Até R$ 100,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 100,00")
            break
        case "Até R$ 500,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 500,00")
            break
        case "Até R$ 1.000,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 1.000,00")
            break
        case "Até R$ 2.000,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 2.000,00")
            break
        case "Até R$ 3.000,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 3.000,00")
            break
        case "Até R$ 5.000,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 5.000,00")
            break
        case "Até R$ 10.000,00":
            self.queryJobs.whereKey("payment", equalTo: "Até R$ 10.000,00")
            break
        case "+ R$ 10.000,00":
            self.queryJobs.whereKey("payment", equalTo: "+ de R$ 10.000,00")
            break
        default:
            break
        }
        
        self.jobs.removeAll()
        self.refreshData()
    }
    
    /**
     Make the query, fill the jobs list and refresh table data
     - returns: Void
     */
    
    private func refreshData() {
        var flagJobRepeated = false
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
        self.queryJobs.cancel()
        self.getLimitRecordFromTable()
        
        //Pagination
        self.queryJobs.limit = self.stepPage
        if (self.countPage > 0) {
            self.queryJobs.skip = self.countPage * self.stepPage
        }
        self.queryJobs.cachePolicy = .CacheThenNetwork
        self.queryJobs.orderByDescending("createdAt")
        self.queryJobs.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    
                    if objects.count == 0 {
                        self.displayAlert("Oops :(", messageAlert: "Parece que não há nenhum trabalho cadastrado nessa categoria")
                    }
                    
                    for object in objects {
                        flagJobRepeated = false
                        for job in self.jobs {
                            if job.objectId == object.objectId {
                                flagJobRepeated = true
                            }
                        }
                        
                        if !flagJobRepeated {
                            self.jobs.append(object)
                        }
                    }
                }
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            
            if self.refresher.refreshing {
                self.refresher.endRefreshing()
            }
            
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        })
    }
    
    /**
     Show a refresher element when user pull down the table
     - parameter sender: of type AnyObject
     - returns: Void
     */
    
    func refresherWork(sender:AnyObject) {
        self.maxRow = 0
        self.maxPage = 0
        self.countPage = 0
        self.configureQuery()
    }
    
    /**
     Count all of jobs and set the variables responsable of query limit
     - parameter sender: of type UIButton
     - returns: Void
     */
    
    func getLimitRecordFromTable() {
        let queryLocal = PFQuery(className: "Job")
        queryLocal.countObjectsInBackgroundWithBlock({
            (countLocal: Int32, errorLocal: NSError?) -> Void in
            if (errorLocal == nil) {
                self.maxRow = Int(countLocal) //Limit for pagination
                self.maxPage = Int(self.maxRow/self.stepPage) + 1
            }
        })
    }
    
    /**
     Add the "Done" button to keyboard
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
        self.filterChoosed.inputAccessoryView = keyboardToolbar
    }
    
    /**
     Show the alert for confirm delete action and make the deletion
     - parameter indexPath: The indexPath of row
     - parameter row: The number of row in indexPath
     - returns: Void
     */
    
    func confirmDelete(indexPath: NSIndexPath, row: Int) {

        /// Define if job will be come from jobs list or filtereJobs list
        let job = (self.searchController.active && self.searchController.searchBar.text != "") ? self.filteredJobs[indexPath.row] : self.jobs[indexPath.row]
        
        let alert = UIAlertController(title: "Apagar \(job["type"]!)", message: "Tem certeza que quer apagar permanentemente esse \(job["type"]!)?", preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancelar", style: .Cancel) { action -> Void in }
        
        let deleteAction: UIAlertAction = UIAlertAction(title: "Apagar", style: .Destructive) { action -> Void in
            self.user!["interested"]!.removeObject(job.objectId!)
            self.user!.saveInBackground()
            job.deleteInBackground()
            self.tableView.beginUpdates()
            
            if self.searchController.active && self.searchController.searchBar.text != "" {
                self.filteredJobs.removeAtIndex(row)
            } else {
                self.jobs.removeAtIndex(row)
            }
            
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
            self.refreshData()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        // Support display in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0,
        self.view.bounds.size.height, 1.0, 1.0)
        self.presentViewController(alert, animated: true, completion: nil)
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
            self.displayAlert("Oops :(", messageAlert: "Ocorreu um erro ao acessar o aplicativo de email :(")
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
