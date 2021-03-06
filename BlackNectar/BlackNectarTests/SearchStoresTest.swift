//
//  SearchStoresTest.swift
//  BlackNectar
//
//  Created by Cordero Hernandez on 1/17/17.
//  Copyright © 2017 BlackSource. All rights reserved.
//

@testable import BlackNectar

import MapKit
import XCTest


class SearchStoresTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSearchForStoresLocations() {
        
        let usersLatitude: CLLocationDegrees = 40.6782
        let usersLongitude: CLLocationDegrees = -73.9442
        let userLocation = CLLocationCoordinate2D(latitude: usersLatitude, longitude: usersLongitude)
        
        
        let promise = expectation(description: "Callback will be called")
        
        let testCallback: ([Store]) -> Void = { stores in
            
            if !stores.isEmpty {
                promise.fulfill()
            }
            
        }
        
        SearchStores.searchForStoresLocations(near: userLocation,  callback: testCallback)
        
        waitForExpectations(timeout: 3, handler: nil)
        
    }
    
    func testSearchForStoresByName() {
        
        let storeName: String = "Vons"
        
        let promise = expectation(description: "Callback will be called")
        
        let testCallback: ([Store]) -> Void = { stores in
            
            if !stores.isEmpty {
                promise.fulfill()
            }
            
        }
        
        SearchStores.searchForStoresByName(withName: storeName, callback: testCallback)
        
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testSearchForStoresByZipCode() {
        
        let storeZipCode = "91403"
        
        let promise = expectation(description: "Callback will be called")
        
        let testCallback: ([Store]) -> Void = { stores in
            
            if !stores.isEmpty {
                promise.fulfill()
            }
            
        }
        
        SearchStores.searchForStoresByZipCode(withZipCode: storeZipCode, callback: testCallback)
        
        waitForExpectations(timeout: 3.0, handler: nil)
        
    }
    
}
