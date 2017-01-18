//
//  ViewController.swift
//  BlackNectar
//
//  Created by Cordero Hernandez on 11/19/16.
//  Copyright © 2016 Black Whole. All rights reserved.
//

import Archeota
import AromaSwiftClient
import CoreLocation
import Foundation
import Kingfisher
import MapKit
import UIKit


class StoresMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentCoordinates: CLLocationCoordinate2D?
    var storesInMapView: [StoresInfo] = []
    var selectedPin: MKPlacemark?
    var distance = 0.0
    var showRestaurants = false
    var showStores = false
    var onlyShowOpenStores = true
    let userLocationManager = UserLocation.instance
    var mapViewLoaded = false
    
    typealias Callback = ([StoresInfo]) -> ()
    
    fileprivate let async: OperationQueue = {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 10
        
        return operationQueue
    }()
    
    fileprivate let main = OperationQueue.main
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareMapView()
        loadStores()
        
        AromaClient.beginMessage(withTitle: "User Entered Map View")
            .addBody("Users location is: \(UserLocation.instance.currentCoordinate)")
            .withPriority(.medium)
            .send()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func loadStores() {
        
        UserLocation.instance.requestLocation() { coordinate in
            self.loadStoresInMapView(at: coordinate)
        }
        
    }
    
    private func prepareMapView() {
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        guard let region = UserLocation.instance.currentRegion else {
            
            LOG.error("Failed to Update the Users Current Region")
            return
        }
        
        self.mapView.setRegion(region, animated: true)
    }
    
}

//MARK: Loading Stores Into View
extension StoresMapViewController {
    
    func loadStoresInMapView(at coordinate: CLLocationCoordinate2D) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let distanceInMeters = DistanceCalculation.milesToMeters(miles: Double(distance))
        
        SearchStores.searchForStoresLocations(near: coordinate, with: distanceInMeters) { stores in
            
            self.storesInMapView = stores
            
            self.main.addOperation {
                self.populateStoreAnnotations()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
    }
    
    func populateStoreAnnotations() {
        
        var annotations: [MKAnnotation] = []
        
        for store in storesInMapView {
            
            let annotation = createAnnotation(forStore: store)
            annotations.append(annotation)
        }
        
        mapView.addAnnotations(annotations)
        mapView.removeNonVisibleAnnotations()
    }
    
    private func createAnnotation(forStore store: StoresInfo) -> CustomAnnotation {
        
        let storeName = store.storeName
        let address = store.address.allValues
        let location = store.location
        
        let latitude = location.latitude
        let longitude = location.longitude
        
        let annotation = CustomAnnotation(name: storeName, latitude: latitude, longitude: longitude)
        
        return annotation
    }
    
    
}


//MARK: Map View Delegate Methods
extension StoresMapViewController {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotation = annotation as? CustomAnnotation
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        let blackNectarPin = UIImage(named: "NectarMapPin")
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation?.identifier)

        button.setBackgroundImage(UIImage(named: "carIcon"), for: .normal)

        annotationView.canShowCallout = true
        annotationView.leftCalloutAccessoryView = button
        annotationView.image = blackNectarPin
        
        return annotationView
        
    }
    
}

//MARK: Geting Directions
extension StoresMapViewController {
    
    func getDrivingDirections(to storeCoordinates: CLLocationCoordinate2D, with storeName: String) -> MKMapItem {
        
        let storePlacemark = MKPlacemark(coordinate: storeCoordinates, addressDictionary: [ "\(title)" : storeName ])
        let storePin = MKMapItem(placemark: storePlacemark)
        storePin.name = storeName
        
        return storePin
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let appleMapslaunchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        if let storeLocation = view.annotation {
            
            let storeName: String = (storeLocation.title ?? nil) ?? "Uknown"
            
            getDrivingDirections(to: storeLocation.coordinate, with: storeName).openInMaps(launchOptions: appleMapslaunchOptions)
            
        }
        
    }
    
    
}

extension StoresMapViewController {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        
        let center = mapView.centerCoordinate
        
        LOG.debug("User dragged Map Screen to: \(center)")
        
        self.loadStoresInMapView(at: center)
    }
    
}


fileprivate extension MKMapView {
    
    func isVisible(annotation: MKAnnotation) -> Bool {
        
        let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
        return MKMapRectContainsPoint(self.visibleMapRect, annotationPoint)
    }
    
    func removeNonVisibleAnnotations() {
        
        self.annotations
            .filter({ !isVisible(annotation: $0)})
            .forEach({ self.removeAnnotation($0) })
    }
}

