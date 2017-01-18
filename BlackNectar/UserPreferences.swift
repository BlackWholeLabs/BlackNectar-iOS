//
//  UserDefaults.swift
//  BlackNectar
//
//  Created by Kevin Bradbury on 1/18/17.
//  Copyright © 2017 Black Whole. All rights reserved.
//

import Foundation


class UserPreferences: NSObject {
    
    static let instance = UserPreferences()
    private override init() {}
    
    let defaultPreferences = UserDefaults.standard
    
    func setUserPreferences(distanceFilter: Double, isRestaurant: Bool, isOpenNow: Bool, isStore: Bool) {
        
        defaultPreferences.set(distanceFilter, forKey: "distanceFilter")
        defaultPreferences.set(isRestaurant, forKey: "isRestaurant")
        defaultPreferences.set(isOpenNow, forKey: "isOpenNow")
        defaultPreferences.set(isStore, forKey: "isStore")
        
    }
    
    func loadDefaults() -> ([String : Any]) {
        
        var distanceFilter = 0.0
        var isRestaurant = false
        var isOpenNow = false
        var isStore = false
        
        if defaultPreferences.double(forKey: "distanceFilter") > 0 {
            
            distanceFilter = defaultPreferences.double(forKey: "distanceFilter")
            isRestaurant = defaultPreferences.bool(forKey: "isRestaurant")
            isOpenNow = defaultPreferences.bool(forKey: "isOpenNow")
            isStore = defaultPreferences.bool(forKey: "isStore")
            
        }
        
        return ([
            "distanceFilter" : distanceFilter,
            "onlyShowOpenStores" : isOpenNow,
            "showRestaurants" : isRestaurant,
            "showStores" : isStore
            
            ])
        
    }
    
    func setSideMenuDefaults(viewController: SideMenuFilterViewController, distanceFilter: Double, isRestaurant: Bool, isOpenNow: Bool, isStore: Bool) {
        
        let roundedNumber = (round(defaultPreferences.double(forKey: "distanceFilter") * 100)/100)
        
        viewController.slider.value = Float(defaultPreferences.double(forKey: "distanceFilter"))
        viewController.slideValueLabel.text = "\(roundedNumber)"
        
        if isRestaurant {
            
            viewController.styleButtonOn(button: viewController.restaurantButton)
            
        } else {
            
            viewController.styleButtonOff(button: viewController.restaurantButton)
            
        }
        
        if isOpenNow {
            
            viewController.openNowSwitch.isOn = true
            
        } else {
            
            viewController.openNowSwitch.isOn = false
            
        }
        
        if isStore {
            
            viewController.styleButtonOn(button: viewController.storesButton)
            
        } else {
            
            viewController.styleButtonOff(button: viewController.storesButton)
            
        }
        
    }
    
}
