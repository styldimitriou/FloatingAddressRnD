//
//  MarkerAddressView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 30/08/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

class MarkerAddressView: UIView {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerAddressView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupView(_ addressText: String, _ color: UIColor) {
        self.addressLabel.text = addressText
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layoutIfNeeded()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.backgroundColor = color
        self.layer.zPosition = .greatestFiniteMagnitude
    }
}
