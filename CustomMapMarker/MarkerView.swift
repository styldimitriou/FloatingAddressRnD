//
//  MarkerView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 26/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

enum Position: String {
    case topLeft, topRight, bottomLeft, bottomRight
    
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

class MarkerView: UIView {
    
    var addressView: MarkerAddressView!
    var pinView: MarkerPinView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(_ addressText: String) {
        self.init()
        
        addressView = loadAddrNiB()
        addressView.setupView(addressText)
        let addressViewWidth = addressView.frame.width
        let addressViewHeight = addressView.frame.height
        
        pinView = loadPinNiB()
        pinView.setupView()
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
    
    func loadAddrNiB() -> MarkerAddressView {
        let addressView = MarkerAddressView.instanceFromNib() as! MarkerAddressView
        return addressView
    }
    
    func loadPinNiB() -> MarkerPinView {
        let pinView = MarkerPinView.instanceFromNib() as! MarkerPinView
        return pinView
    }

}
