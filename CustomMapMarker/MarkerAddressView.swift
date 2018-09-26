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
    @IBOutlet weak var iconFontLabel: UILabel!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerAddressView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupView(_ addressText: String) {
        self.addressLabel.text = addressText
        self.iconFontLabel.text = ""
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addressLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.4).isActive = true
        self.layoutIfNeeded()
        
        self.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 40.0 / 255.0, alpha: 1.0).cgColor
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        self.backgroundColor = .white
        self.layer.zPosition = .greatestFiniteMagnitude        
    }
}
