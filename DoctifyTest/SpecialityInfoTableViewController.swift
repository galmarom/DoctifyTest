//
//  SpecialityInfoTableViewController.swift
//  DoctifyTest
//
//  Created by galmarom on 17/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit

class SpecialityInfoTableViewController: UITableViewController {

    var specilaistDetailsURL : String?
    var specialityId : Int?{
        didSet{
            specilaistDetailsURL = "/api/v2/keywords/\(specialityId!)"
        }
    }
    //Functions as the DataSource. The title and value will be saved as truple. and will be present at the table accordingly
    var specialityInfoArray = [(title : String,value : String)]()
    
    //Constants
    let infoCellId = "specialityInfoCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Adjust the table to multpile sizes of content
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        if(specialityId != nil){
            self.getspecialitysFromUrl()
        }
    }

    
    //Sending a request to retrieve the item from the resource
    func getspecialitysFromUrl(){
        weak var weakSelf = self
        let sourceUrl = NetworkHelper.sharedInstance.baseURL + "/" + self.specilaistDetailsURL!
        NetworkHelper.sendRequest(url: sourceUrl, parameters: nil, withCompletionHandler: { data, response, error in
            guard error == nil else {
                print("An error has occured : " + error!.localizedDescription)
                //Presents an error alert
                let alert = UIAlertController(title: "Error", message:error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style:.cancel, handler: { action in
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).asyncAfter(deadline: .now() + .seconds(5)){
                        weakSelf?.getspecialitysFromUrl()
                    }
                })
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                //tries to retrieve the products again after 5 seconds
                return
            }
            guard data != nil else {
                print("Data is empty")
                return
            }
            do {
                let itemsArray = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Array<Dictionary<String,AnyObject>>
                if itemsArray.count == 1 {
                    let specialityDictionary = itemsArray.first!
                    self.specialityInfoArray = [(title : String,value : String)]()
                    //Checking if the value for the field to represent is valid and adding it to the DataSource "specialityInfoArray"
                    if let name = specialityDictionary["name"] as? String {
                        self.specialityInfoArray.append(("Name:",name))
                        self.title = name
                    }
                    if let description = specialityDictionary["description"] as? String {
                        self.specialityInfoArray.append(("Description:",description))
                    }
                    if let practitioner = specialityDictionary["practitioner"] as? String {
                        self.specialityInfoArray.append(("Practitioner:",practitioner))
                    }
                    if let information = specialityDictionary["attributes"]?["information"] as? String {
                        self.specialityInfoArray.append(("Information:",information))
                    }
                    self.tableView!.reloadData()
                }else{
                    print("There are 0 entries at itemsArray")
                }
            } catch let error as NSError {
                print("An error has occured : " + error.localizedDescription)
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specialityInfoArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "specialityInfoCell", for: indexPath) as! SpecialityInfoCell
        let specialityInfo = self.specialityInfoArray[indexPath.row]
        cell.titleLabel?.text = specialityInfo.title
        cell.descriptionLabel?.text = specialityInfo.value
        return cell
    }


}
