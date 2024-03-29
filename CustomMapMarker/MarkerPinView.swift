//
//  MarkerPinView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 13/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

/**
 A UIVIew subclass that acts like a marker pin
 */
class MarkerPinView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerPinView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    /**
     Configures the pinView and its properties
     */
    func setupView() {
        self.layer.zPosition = .leastNormalMagnitude
    }
}
