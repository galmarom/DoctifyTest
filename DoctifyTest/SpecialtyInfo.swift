//
//  SpecialtyInfo.swift
//  DoctifyTest
//
//  Created by galmarom on 16/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit

class SpecialtyInfo: NSObject {

    var specialityId : Int
    var name : String
    
    var iconURL : String?
    
    /**
     -param jsonDictionary: A <String,AnyObject> dictionary. The dictioanry values will be populated into the new specialityInfo
     
     -note: name and specialityId are mendatory fields - if they don't appear at the dictionary - a nil will be returned

     */
    init?(jsonDictionary: [String:AnyObject]) {
        if let specialityId = jsonDictionary["id"] as? Int, let name = jsonDictionary["name"] as? String{
            self.specialityId = specialityId
            self.name = name
        }else{
            print("jsonDictionary doen't contain one of the mendatory entries (name and id). \(jsonDictionary)")
            return nil
        }
        if let iconURL = jsonDictionary["icon_uri"] as? String{
            self.iconURL = iconURL
        }
    }
    override var debugDescription: String{
        return "ClothItem: id: \(specialityId), name: \(name), iconURL: \(iconURL)"
    }
    
    /**
     Returns the image name , i.e the last component, of the iconURL 
    */
    func getImageName() -> String?{
        if let iconURL = iconURL{
            let indexOfLastSlash = iconURL.range(of: "/", options: String.CompareOptions.backwards)?.lowerBound
            //Separating the image name
            var imageName = indexOfLastSlash != nil ? iconURL.substring(from:indexOfLastSlash!) : iconURL
            if imageName.characters.first == "/"{
                imageName = imageName.substring(from:1)
            }
            return imageName
        }
        return nil
    }
    
}
