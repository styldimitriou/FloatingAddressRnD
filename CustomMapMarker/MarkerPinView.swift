//
//  MarkerPinView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 13/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

class MarkerPinView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerPinView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupView(_ color: UIColor) {
        self.backgroundColor = color
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 1
        self.layer.zPosition = .leastNormalMagnitude
    }
}
