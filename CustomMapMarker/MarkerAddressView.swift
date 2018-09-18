//
//  MarkerAddressView.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 30/08/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit

//protocol MapMarkerDelegate: class {
//    func didTapInfoButton(data: NSDictionary)
//}

class MarkerAddressView: UIView {
    
    @IBOutlet weak var addressLabel: UILabel!
    
//    weak var delegate: MapMarkerDelegate?
//    var spotData: NSDictionary?
    
//    @IBAction func didTapInfoButton(_ sender: UIButton) {
//        delegate?.didTapInfoButton(data: spotData!)
//    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerAddressView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
}
