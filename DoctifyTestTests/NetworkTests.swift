//
//  NetworkTests.swift
//  DoctifyTest
//
//  Created by galmarom on 17/11/2016.
//  Copyright © 2016 galmarom. All rights reserved.
//

import XCTest
@testable import DoctifyTest

class NetworkTests: XCTestCase {
    
     var (urlExample,isJson) : (String,Bool) = {
        return  ("\(NetworkHelper.sharedInstance.baseURL)/\(RateExchangeHelper.sharedInstance.exchangeRatesURL)",true)
    }()


    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    

    func testSendHTTPRequest(){
        NetworkHelper.sendRequest(url: self.urlExample, parameters: nil, withCompletionHandler: { data, urlResponse,error in
            XCTAssertNotNil(data,"Data from url \(self.urlExample) is nil")
            if(data != nil && self.isJson){
                XCTAssertTrue(JSONSerialization.isValidJSONObject(data!),"\(self.urlExample) is not a valid json")
            }
            XCTAssertNil(error,"Error while sending url request: \(self.urlExample). \(error!)")
        })
    }
    
}
