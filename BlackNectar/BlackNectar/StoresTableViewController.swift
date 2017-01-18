//
//  StoresTableViewController.swift
//  BlackNectar
//
//  Created by Cordero Hernandez on 11/28/16.
//  Copyright © 2016 Black Whole. All rights reserved.
//

import Archeota
import AromaSwiftClient
import CoreLocation
import Foundation
import Kingfisher
import MapKit
import SWRevealController
import UIKit


//TODO: Integrate with Carthage

class StoresTableViewController: UITableViewController, SideMenuFilterDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    var stores: [StoresInfo] = []
    var distanceFilter = 0.0
    var showRestaurants = false
    var showStores = false
    var onlyShowOpenStores = true
    let edgeGesture = UIScreenEdgePanGestureRecognizer()
    var panningWasTriggered = false
    var defaults: [String : Any] = [:]
    
    let async: OperationQueue = {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        
        return operationQueue
        
    }()
    
    fileprivate let main = OperationQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stores.removeAll()
        
        UserLocation.instance.initialize()
        configureSlideMenu()
        setupRefreshControl()
        passDefaultValues()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setEdgeGesture()
        
        UserLocation.instance.requestLocation() { coordinate in
            self.loadStores(at: coordinate)
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
        
        AromaClient.sendLowPriorityMessage(withTitle: "Filter Opened")
        LOG.info("Opening Filter")
        
    }
    
    
    func didApplyFilters(_ filter: SideMenuFilterViewController, restaurants: Bool, stores: Bool, openNow: Bool, distanceInMiles: Int) {
        
        showRestaurants = restaurants
        showStores = stores
        onlyShowOpenStores = openNow
        distanceFilter = Double(distanceInMiles)
        
        if let currentLocation = UserLocation.instance.currentCoordinate {
            
            loadStores(at: currentLocation)
            
        }
        
    }
    
    func didCancelFilters() {
        
        AromaClient.sendLowPriorityMessage(withTitle: "Filter Cancelled")
        LOG.info("Cancelling Filter")
        
    }
    
    fileprivate func loadStores(at coordinate: CLLocationCoordinate2D) {
        
        networkLoadingIndicatorIsSpinning()
        
        let distanceInMeters = DistanceCalculation.milesToMeters(miles: distanceFilter)
        
        SearchStores.searchForStoresLocations(near: coordinate, with: distanceInMeters) { stores in
            self.stores = stores
            
            self.main.addOperation {
                
                self.tableView.reloadData()
                
                self.networkLoadingIndicatorIsNotSpinning()
                self.refreshControl?.endRefreshing()
                
            }
            
        }
        
    }
    
    fileprivate func configureSlideMenu() {
        
        guard let menu = self.revealViewController() else { return }
        
        if let gesture = menu.panGestureRecognizer() {
            
            self.view.addGestureRecognizer(gesture)
            
        }
        
        guard let sideMenu = menu.rearViewController as? SideMenuFilterViewController else { return }
        
        sideMenu.delegate = self
        
        
    }
    
    func goLoadImage(into cell: StoresTableViewCell, withStore url: URL) {
        
        let fade = KingfisherOptionsInfoItem.transition(.fade(0.5))
        let scale = KingfisherOptionsInfoItem.scaleFactor(UIScreen.main.scale * 2)
        let options: KingfisherOptionsInfo = [fade, scale]
        
        cell.storeImage.kf.setImage(with: url, placeholder: nil, options: options, progressBlock: nil, completionHandler: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapViewSegue" {
            
            let destination = segue.destination as? StoresMapViewController
            
            destination?.distance = distanceFilter
            destination?.onlyShowOpenStores = self.onlyShowOpenStores
            destination?.showRestaurants = self.showRestaurants
            destination?.showStores = self.showStores
            destination?.storesInMapView = self.stores
            
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
            
            LOG.error("Failed to dequeue StoresTableViewCell")
            return UITableViewCell()
            
        }
        
        let store = stores[indexPath.row]
        var addressString = ""
        
        
        if let currentLocation = UserLocation.instance.currentCoordinate {
            
            var distance = 0.0
            distance = DistanceCalculation.getDistance(userLocation: currentLocation, storeLocation: store.location)
            distance = DistanceCalculation.meteresToMiles(meters: distance)
            let doubleDown = Double(round(distance * 100)/100)
            
            cell.storeDistance.text = "\(doubleDown) miles"
        }
        
        
        
        //WTF IS THIS? FUNCTION PLEASE
        //Call it, combine addresses
        //PLEASE 🙏🏽
        addressString = (store.address["address_line_1"] as? String)! + "\n" + (store.address["city"] as? String)! + ", " + (store.address["state"] as? String)!
        
        goLoadImage(into: cell, withStore: store.storeImage)
        cell.storeName.text = store.storeName
        cell.storeAddress.text = addressString
        cell.onGoButtonPressed = { cell in
            self.navigate(toStore: store)
        }
        

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

//MARK - Pull to Refresh Code
extension StoresTableViewController {
    
    func setupRefreshControl() {
        
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.black
        refreshControl?.tintColor = UIColor.init(red: 0.902, green: 0.73, blue: 0.25, alpha: 1)
        
        refreshControl?.addTarget(self, action: #selector(self.reloadStoreData), for: .valueChanged)
        
    }
    
    func reloadStoreData() {
        
        if let usersCurrentLocation = UserLocation.instance.currentCoordinate {
            
            loadStores(at: usersCurrentLocation)
            
        }
        
    }
    
}

//MARK - UI Screen Pan Gesture Code
extension StoresTableViewController {
    
    func setEdgeGesture() {
        
        edgeGesture.addTarget(self, action: #selector(self.handleRightEdge(gesture:)))
        edgeGesture.edges = .right
        edgeGesture.delegate = self
        
        self.view.addGestureRecognizer(edgeGesture)
        
    }
    
    func handleRightEdge(gesture: UIScreenEdgePanGestureRecognizer) {
        
        switch gesture.state {
            
        case .began, .changed:
            
            setGestureProperties()
            
        case .cancelled, .failed:
            
            panningWasTriggered = false
            
        default: break
            
        }
        
    }
    
    func setGestureProperties() {
        
        if !panningWasTriggered {
            
            let threshold: CGFloat = 20
            let translation = abs(edgeGesture.translation(in: view).x)
            
            if translation >= threshold {
                
                performSegue(withIdentifier: "mapViewSegue", sender: nil)
                
                panningWasTriggered = true
                
            }
            
        }

    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        
        return true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return false
      
    }
    
}

//MARK - Navigation Code
fileprivate extension StoresTableViewController {
    
    func navigate(toStore store: StoresInfo) {
        
        let appleMapsLaunchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeKey]
        
        let storePlacemark = MKPlacemark(coordinate: store.location, addressDictionary: ["\(title)" : store.storeName])
        let storePin = MKMapItem(placemark: storePlacemark)
        storePin.name = store.storeName
        
        storePin.openInMaps(launchOptions: appleMapsLaunchOptions)
        
    }
    
}

//MARK - Network Loading Indicator Code
fileprivate extension StoresTableViewController {

    
    func networkLoadingIndicatorIsSpinning() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    func networkLoadingIndicatorIsNotSpinning() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
    }
    
}

//MARK - Sets User Preferences for various filters
fileprivate extension StoresTableViewController {
    
    func passDefaultValues() {
        
        defaults = UserPreferences.instance.loadDefaults()
        
        onlyShowOpenStores = defaults["onlyShowOpenStores"] as! Bool
        showRestaurants = defaults["showRestaurants"] as! Bool
        distanceFilter = defaults["distanceFilter"] as! Double
        showStores = defaults["showStores"] as! Bool
            print(onlyShowOpenStores, showRestaurants, distanceFilter, showStores)
    }
    
}


