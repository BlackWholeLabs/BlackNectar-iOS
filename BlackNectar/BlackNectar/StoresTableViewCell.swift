//
//  StoresTableViewCell.swift
//  BlackNectar
//
//  Created by Cordero Hernandez on 11/30/16.
//  Copyright © 2017 BlackSource. All rights reserved.
//

import Foundation
import MapKit
import UIKit


class StoresTableViewCell: UITableViewCell {
    
    @IBOutlet weak var storeImage: UIImageView!
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var storeDistance: UILabel!
    
    var onGoButtonPressed: ((StoresTableViewCell) -> ())?
    
    @IBAction func didTapGoButton(_ sender: Any) {
        
        onGoButtonPressed?(self)
    }
    
}
