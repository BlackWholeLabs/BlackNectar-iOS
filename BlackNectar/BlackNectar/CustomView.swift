//
//  CustomerView.swift
//  BlackNectar
//
//  Created by Wellington Moreno on 3/2/17.
//  Copyright © 2017 BlackSource. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CustomView : UIView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override func prepareForInterfaceBuilder() {
        
        updateView()
        
    }
    
    @IBInspectable var circular: Bool = false {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1 {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shouldRasterize: Bool = false {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowOffSet: CGSize = CGSize(width: 3, height: 0) {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 5 {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rotation: CGFloat = 0 {
        
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        
        if shouldRasterize {
            layer.rasterizationScale = UIScreen.main.scale
        }
        
        let rotationDegrees = Int(rotation) % 360
        
        if rotationDegrees != 0 {
            
            let rotationAngleRadians = Double(rotationDegrees) * (M_PI / 180.0)
            self.transform = CGAffineTransform(rotationAngle: CGFloat(rotationAngleRadians))
        }
        else {
            
            self.transform = CGAffineTransform.identity
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateView()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateView()
        
    }
    
}
