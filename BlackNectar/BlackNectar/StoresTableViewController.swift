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
import SWRevealController

//TODO: Integrate with Carthage

class StoresTableViewController: UITableViewController, SideMenuFilterDelegate {
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    var stores: [StoresInfo] = []
    var distanceFilter: Int?
    var isRestaurant: Bool?
    var isStore: Bool?
    var openNowSwitch: Bool?
    
    let async: OperationQueue = {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
       
        return operationQueue
        
    }()
    
    private let main = OperationQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserLocation.instance.initialize()
        configureSlideMenu()
        setFilterDelegate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let currentLocation = UserLocation.instance.currentCoordinate {
            
            loadStores(at: currentLocation)
            
        } else {
            
            UserLocation.instance.requestLocation() { coordinate in
                self.loadStores(at: coordinate)
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onFilterTapped(_ sender: Any) {
        
        if let revealController = self.revealViewController() {
            revealController.revealToggle(animated: true)
        }

    }
    
    func onApply(_ filter: SideMenuFilterViewController, restaurants: Bool, stores: Bool, openNow: Bool, distanceInMiles: Int) {
        
        isRestaurant = restaurants
        isStore = stores
        openNowSwitch = openNow
        distanceFilter = distanceInMiles
        
    }
    
    func onCancel() {
        print("onCancel func hit")
    }
    
    private func setFilterDelegate() {
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let filterViewController: SideMenuFilterViewController = mainStoryBoard.instantiateViewController(withIdentifier: "child") as! SideMenuFilterViewController
        filterViewController.delegate = self
        
        if filterViewController.delegate != nil {
        } else {
            print("set filter delegate function delegate wasn't set")
        }
        
    }
    
    
    private func loadStores(at coordinate: CLLocationCoordinate2D) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        SearchStores.searchForStoresLocations(near: coordinate) { stores in
            self.stores = stores
            
            self.main.addOperation {
                
                self.tableView.reloadData()
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
            
        }
        
    }
    
    
    fileprivate func configureSlideMenu() {
        
        guard let menu = self.revealViewController() else { return }
        
        if let gesture = menu.panGestureRecognizer() {
            
             self.view.addGestureRecognizer(gesture)
            
        }
        
        guard let nav = menu.rearViewController as? UINavigationController else { return }
        guard let sideMenu = nav.topViewController as? SideMenuFilterViewController else { return }
        
        sideMenu.delegate = self
        
    }
    
    func goLoadImage(into cell: StoresTableViewCell, withStore url: URL) {
        
        async.addOperation {
            
            do {
                let data = try Data(contentsOf: url)
                let image = try UIImage(data: data)
                
                
                self.main.addOperation {
                    cell.storeImage.image = image
                    
                }
                
            } catch {
                print("error")
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return stores.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "storeCell", for: indexPath) as? StoresTableViewCell else {
            return UITableViewCell()
        }
        
        let store = stores[indexPath.row]
        var addressString = ""
        
        //WTF IS THIS? FUNCTION PLEASE
        //Call it, combine addresses
        //PLEASE 🙏🏽
        addressString = (store.address["address_line_1"] as? String)! + "\n" + (store.address["city"] as? String)! + ", " + (store.address["state"] as? String)!
        
        goLoadImage(into: cell, withStore: store.storeImage)
        cell.storeName.text = store.storeName
        cell.storeAddress.text = addressString
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cellAnimation = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
        cell.alpha = 0
        
        self.main.addOperation {
            
            cell.layer.transform = cellAnimation
            
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1.0
                cell.layer.transform = CATransform3DIdentity
                
            }
            
        }
        
    }
    
    
   
    
}
