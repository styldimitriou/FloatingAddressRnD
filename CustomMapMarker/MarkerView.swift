//
//  MarkerView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 26/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

/**
    The available positions of an addressView
 
 # Positions
 - topLeft
 - topRight
 - bottomLeft
 - bottomRight
 */
enum Position: String {
    case topLeft, topRight, bottomLeft, bottomRight
    
    /**
     - Parameter addressViewFrame: The frame of the addressView
     - Parameter dimensions: The dimensions (width, height) of the marker's iconView
     
     - Returns: A CGPoint of the addressView position origin
     */
    func positionCoordinates(for addressViewFrame: CGRect, dimensions: (width: CGFloat, height: CGFloat)) -> CGPoint {
        switch self {
        case .topLeft:
            return CGPoint(x: 0.0, y: 0.0)
        case .topRight:
            return CGPoint(x: dimensions.width - addressViewFrame.width, y: 0.0)
        case .bottomLeft:
            return CGPoint(x: 0.0, y: dimensions.height - addressViewFrame.height)
        case .bottomRight:
            return CGPoint(x: dimensions.width - addressViewFrame.width, y: dimensions.height - addressViewFrame.height)
        }
    }
}

/**
 A UIView subclass that consists of an address view and a pin view
 */
class MarkerView: UIView {
    
    var addressView: MarkerAddressView!
    var pinView: MarkerPinView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /**
     Initializes a new MarkerView
     
     - Parameter addressText: The text to be displayed on the addressView label
     */
    convenience init(_ addressText: String) {
        self.init()
        
        // Initialize the addressView
        addressView = loadAddrNiB()
        addressView.setupView(addressText)
        
        // Get addressView width and height to be used for the MarkerView frame initialization
        let addressViewWidth = addressView.frame.width
        let addressViewHeight = addressView.frame.height
        
        // Initialize the pinView
        pinView = loadPinNiB()
        pinView.setupView()
        
        // Get pinView width and height to be used for the MarkerView frame initialization
        let pinViewWidth = pinView.frame.width
        let pinViewHeight = pinView.frame.height
        
        let padding: CGFloat = 10.0
        let backViewWidth = 2 * addressViewWidth + pinViewWidth + padding
        let backViewHeight = 2 * addressViewHeight + pinViewHeight + padding
        
        self.frame = CGRect(x: 0, y: 0, width: backViewWidth, height: backViewHeight)
        self.addSubview(addressView)
        self.addSubview(pinView)
        self.layoutIfNeeded()
//        self.backgroundColor = UIColor.red
//        self.alpha = 0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Sets the constraints of the MarkerView and its subviews (addressView and pinView)
     */
    func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addressView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        addressView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        pinView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        
        self.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
    }
    
    /**
     Loads an addressView from Nib
     
     - Returns: A new addressView
     */
    func loadAddrNiB() -> MarkerAddressView {
        let addressView = MarkerAddressView.instanceFromNib() as! MarkerAddressView
        return addressView
    }
    
    /**
     Loads a pinView from Nib
     
     - Returns: A new pinView
     */
    func loadPinNiB() -> MarkerPinView {
        let pinView = MarkerPinView.instanceFromNib() as! MarkerPinView
        return pinView
    }

}
