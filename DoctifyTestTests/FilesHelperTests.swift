//
//  FilesHelperTest.swift
//  DoctifyTest
//
//  Created by galmarom on 17/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import XCTest
@testable import DoctifyTest

class FilesHelperTests: XCTestCase {
    
    let testImageName = "doctifyLogo.png" //Image to be saved
    let testImageFileName = "testImage.jpg"   //saved image path
    
    var fileFullPath : URL {
        let documentDirectoryPath = FileHelper.getDocumentsDirectory()
        return documentDirectoryPath.appendingPathComponent(testImageFileName)
    }
    
    var isTestFileExistInPath : Bool {
        return FileManager.default.fileExists(atPath: fileFullPath.absoluteString)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSaveImageFile(){
        if isTestFileExistInPath {
            testDeleteFile()
        }
        self.saveTestImageFile(withCompletion:{ imageLocation in
            XCTAssertNotNil(imageLocation,"Image wasn't saved successfully")
            XCTAssertTrue(self.isTestFileExistInPath,"Image wasn't saved successfully")
            if self.isTestFileExistInPath {
                self.testDeleteFile()
            }
        })
    }
    
    func testLoadImageFileTestFile(){
        if !isTestFileExistInPath {
            weak var weakSelf = self
            _ = saveTestImageFile(withCompletion:{ url in
                FileHelper.loadImage(path: (weakSelf?.testImageFileName)!, withCompletion: {
                    image in
                    XCTAssertNotNil(image,"Coudn't load \(weakSelf?.testImageFileName)")
                })
            })
        }
    }
    
    func testDeleteFile(){
        if !isTestFileExistInPath {
            weak var weakSelf = self
            self.saveTestImageFile(withCompletion:{ imageLocation in
                FileHelper.deleteFile(atPath: (weakSelf?.testImageFileName)!, withCompletion: { isImagedDeleted in
                    XCTAssertTrue(isImagedDeleted,"Coudn't delete \(weakSelf?.testImageName)")
                    XCTAssertFalse((weakSelf?.isTestFileExistInPath
                        )!
                        ,"Coudn't delete \(weakSelf?.testImageName)")
                })
            })
        }
    }
    
    
    private func saveTestImageFile(withCompletion completion:@escaping (URL?) -> Swift.Void){
        let testImage = UIImage(named:testImageName)
        weak var weakSelf = self
        FileHelper.save(image: testImage!, imageName: self.testImageFileName, directory: nil, withCompletion: { url, error in
            XCTAssertNotNil(url,"Coudn't save \(weakSelf?.testImageFileName)")
            XCTAssertNil(error,"Error while saving \(weakSelf?.testImageFileName). \(error!)")
            completion(url)
        })
    }
    
}
