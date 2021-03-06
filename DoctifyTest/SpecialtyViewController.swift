//
//  SpecialtyViewController.swift
//  DoctifyTest
//
//  Created by galmarom on 16/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit

class SpecialtyViewController: UITableViewController, UISplitViewControllerDelegate {

    //Constants
    static let specialitysURL = "api/v2/keywords/specialty"
    let specialityCellId = "specialityCell"
    let imagesDirectoryName = "icons"

    //UI elements
    var activityIndicator: UIActivityIndicatorView?

    //Instance variables
    private var specialityArray = [SpecialtyInfo]()
    private var collapseDetailViewController = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getspecialitiessFromUrl()
        splitViewController?.delegate = self
        self.setSplitViewPrefferedDisplayMode()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.setSplitViewPrefferedDisplayMode()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Sending a request to retrieve the item from the resource
    func getspecialitiessFromUrl(){
        self.animateActivityIndicator(start: true)
        weak var weakSelf = self
        let sourceUrl = NetworkHelper.sharedInstance.baseURL + "/" + SpecialtyViewController.specialitysURL
        NetworkHelper.sendRequest(url: sourceUrl, parameters: nil, withCompletionHandler: { data, response, error in
            guard error == nil else {
                print("An error has occured : " + error!.localizedDescription)
                //Presents an error alert
                let alert = UIAlertController(title: "Error", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style:.cancel, handler: { action in
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).asyncAfter(deadline: .now() + .seconds(5)){
                        weakSelf?.getspecialitiessFromUrl()
                    }
                })
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                //tries to retrieve the products again after 5 seconds
                return
            }
            guard data != nil else {
                print("Data is empty")
                weakSelf?.animateActivityIndicator(start: false)
                return
            }
            do {
                //Parsing the json
                let itemsArray = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Array<Dictionary<String,AnyObject>>
                if itemsArray.count != 0 {
                    self.specialityArray = itemsArray.flatMap{
                        return SpecialtyInfo(jsonDictionary: $0)
                    }
                    DispatchQueue.main.async { [unowned self] in
                        self.tableView!.reloadData()
                        weakSelf?.animateActivityIndicator(start: false)
                    }
                }else{
                    print("There are 0 entries at itemsArray")
                    weakSelf?.animateActivityIndicator(start: false)
                }
            } catch let error as NSError {
                print("An error has occured : " + error.localizedDescription)
            }
        })
    }
    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool{
        return collapseDetailViewController
    }
    
    //MARK: UITableViewControllerDelegate methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specialityArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        collapseDetailViewController = false
    }
    

    //MARK: UITableViewControllerDataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let specialtyCell = tableView.dequeueReusableCell(withIdentifier: specialityCellId)
        let specialityInfo = self.specialityArray[indexPath.row]
        specialtyCell?.textLabel?.text = specialityInfo.name
        specialtyCell?.tag = specialityInfo.specialityId
        //Retriving the speciality's photo
        if let imageName = specialityInfo.getImageName() {
            let imagePath = "\(self.imagesDirectoryName)/\(imageName)"
            //If a file of the photo exists - use it. otherwise, retrive it from the URL and save it
            weak var weakspecialtyCell = specialtyCell
            weak var weakSelf = self
            if FileHelper.fileExists(atPath: imagePath) {
                FileHelper.loadImage(path: imagePath, withCompletion: { (imageFromFile) -> () in
                    if imageFromFile != nil {
                        DispatchQueue.main.async {
                            weakSelf?.setImage(imageFromFile!, inCell: weakspecialtyCell)
                        }
                    }else{
                        print("image is nil at \(imagePath)")
                    }
                })
            }else if let iconURL = specialityInfo.iconURL {
                NetworkHelper.downloadImage(fromURL: NetworkHelper.sharedInstance.baseURL + "/" + iconURL, withCompletionHandler: { image,error in
                    if image != nil {
                        //Saving the photo to the given path: directory/fileName
                        DispatchQueue.main.async {
                            weakSelf?.setImage(image!, inCell: weakspecialtyCell)
                        }
                        FileHelper.save(image: image!, imageName:imageName, directory: weakSelf?.imagesDirectoryName, withCompletion: { url,error in
                            if url == nil {
                                print("Coudn't save image \(imagePath). \(error)")
                            }
                        })
                    }
                })
            }
        }
        return specialtyCell!
    }
    
    private func setImage(_ image: UIImage, inCell cell : UITableViewCell?){
        cell?.imageView?.image = image
        cell?.imageView?.layer.cornerRadius = 10
        cell?.imageView?.layer.masksToBounds = true //bug in iOS9 - will log an error
    }
    
    //MARK: UI methods
    //Start or Stops activity loader on the UI(main) thread
    
    private func setSplitViewPrefferedDisplayMode(){
        if  UIScreen.main.bounds.width < UIScreen.main.bounds.height{
            self.splitViewController?.preferredDisplayMode = .allVisible
        }else{
            self.splitViewController?.preferredDisplayMode = .automatic
        }
    }
    
    private func animateActivityIndicator(start:Bool){
        if self.activityIndicator == nil{
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            self.activityIndicator!.color = UIColor.init(colorLiteralRed: 0.91, green: 0.82, blue: 0.86, alpha: 1)
            self.activityIndicator!.hidesWhenStopped = true
            self.activityIndicator!.center = self.view!.center
            self.view.addSubview(self.activityIndicator!)
        }
        DispatchQueue.main.async {
            self.view.bringSubview(toFront: self.activityIndicator!)
            self.activityIndicator!.isHidden = !start
            if start{
                self.activityIndicator!.startAnimating()
            }else{
                self.activityIndicator!.stopAnimating()
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController{
            destinationVC = navigationVC.visibleViewController ?? destinationVC
        }
        if let specialityInfoTVC = destinationVC as? SpecialityInfoTableViewController {
            let path = tableView.indexPathForSelectedRow
            let cell = tableView.cellForRow(at: path!)
            specialityInfoTVC.specialityId = cell?.tag
            specialityInfoTVC.navigationItem.title = cell?.textLabel?.text
        }
    }
    



}

