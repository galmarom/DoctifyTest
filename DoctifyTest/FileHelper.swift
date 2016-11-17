//
//  FileHelper.swift
//  DoctifyTest
//
//  Created by galmarom on 16/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import UIKit

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}
class FileHelper: NSObject {
    /**
     Returns the user document directory url
     */
    class func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /**
     - returns whether the file exists at the documents directory
     */
    class func fileExists(atPath path:String) -> Bool{
        let fileFullPath = getDocumentsDirectory().appendingPathComponent(path)
        return FileManager.default.fileExists(atPath: fileFullPath.path)
    }
    
    /**
     Saves an image under the given file and directory
     
     - parameter image: The stored image
     - parameter fileName: The file's destination
     - parameter directory: If a directory is given the file will be stored under this directory
     - note The directory will be created if it doesn't already exist
     
     - Calls the completion block with the image URL location (if it was saved successfully) or an error
     */
    class func save(image: UIImage,imageName: String, directory: String?, withCompletion completion: @escaping (URL?,Error?) -> Swift.Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            if let imageData = UIImageJPEGRepresentation(image, 1) {
                //Checking if the directory exists and creating it if it doesn't
                var fileFullPath = getDocumentsDirectory()
                if let directory = directory{
                    fileFullPath = fileFullPath.appendingPathComponent(directory)
                    //Checking if the directory exists and creating it if it doesn't
                    if !self.fileExists(atPath:directory){
                        do {
                            try FileManager.default.createDirectory(atPath: fileFullPath.path, withIntermediateDirectories: false, attributes: nil)
                        } catch let error as NSError {
                            print("Can't create directory for \(fileFullPath). ERROR: " + error.localizedDescription);
                            completion(nil, error)
                        }
                    }
                }
                fileFullPath = fileFullPath.appendingPathComponent(imageName)
                do {
                    try imageData.write(to:fileFullPath, options: .atomicWrite)
                    completion(fileFullPath,nil)
                } catch let error as NSError {
                    print("Can't save image to \(fileFullPath). ERROR: " + error.localizedDescription)
                    completion(nil,error)
                }
            }
        }
    }
    
    /**
     Loading an image from a given path
     
     - parameter path: The image path
     
     - Call the completion block with the image that was loaded from the given path (or with nil if the process was not successful)
     */
    class func loadImage(path: String,withCompletion completion: @escaping (UIImage?) -> Swift.Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let fileFullPath = getDocumentsDirectory().appendingPathComponent(path)
            let image = UIImage(contentsOfFile: fileFullPath.path)
            completion(image)
        }
    }
    
    /**
     Deletes an image at a given path
     
     - parameter path: The image path
     - Calls the completion block with a bool that indicates whether the image was removed successfully
     */
    class func deleteFile(atPath path: String,withCompletion completion: @escaping (Bool) -> Swift.Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            let fileFullPath = getDocumentsDirectory().appendingPathComponent(path)
            do {
                try FileManager.default.removeItem(at: fileFullPath)
                completion(true)
            } catch let error as NSError {
                print("Can't delete file at \(fileFullPath). ERROR: " + error.localizedDescription)
            }
            completion(false)
        }
    }
    
}
