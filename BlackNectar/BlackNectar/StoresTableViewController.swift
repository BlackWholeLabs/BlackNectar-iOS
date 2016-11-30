//
//  StoresTableViewController.swift
//  BlackNectar
//
//  Created by Cordero Hernandez on 11/28/16.
//  Copyright © 2016 Black Whole. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class StoresTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var stores: [StoresInfo] = []
    var currentLocation = UserLocation().prepareForLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserLocation().prepareForLocation()
            print("tableview current location is : \(currentLocation)")
        SearchStores.searchForStoresLocations(near: currentLocation) { stores in
            print("Search for stores, stores is : \(stores)")
            self.stores = stores
        }
        print("stores is \(stores)")
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
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath)
        
        
        
        return cell
    }
    
    
    
    
}