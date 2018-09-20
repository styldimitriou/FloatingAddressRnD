//
//  CustomMarkerVC.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 04/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit
import GoogleMaps

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

class CustomMarkerVC: UIViewController {
    
    var positionsArray: [Position] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    var pickup: GMSMarker = GMSMarker()
    var dropoff: GMSMarker = GMSMarker()
    var pickupAddrPosition: Position!
    var dropoffAddrPosition: Position!
    var markerViewDimensions: (width: CGFloat, height: CGFloat) = (0.0, 0.0)
    var aboveMarkerPin: GMSMarker!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition.camera(withLatitude: 37.98591, longitude: 23.72983, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.camera = camera
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        mapView.settings.tiltGestures = false
        self.view = mapView
        
        // Creates a marker in the center of the map.
        pickup.iconView = markerView("Sina 11", .orange)
        pickup.position = CLLocationCoordinate2D(latitude: 37.98591, longitude: 23.72983)
        pickup.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        pickupAddrPosition = .topLeft
        pickup.map = mapView

        // Creates a second marker
        dropoff.iconView = markerView("Sina 11", .lightGray)
        dropoff.position = CLLocationCoordinate2D(latitude: 37.96591, longitude: 23.73983)
        dropoff.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        dropoffAddrPosition = .topLeft
        dropoff.map = mapView
    }
    
    func loadAddrNiB() -> MarkerAddressView {
        let addressView = MarkerAddressView.instanceFromNib() as! MarkerAddressView
        return addressView
    }
    
    func loadPinNiB() -> MarkerPinView {
        let pinView = MarkerPinView.instanceFromNib() as! MarkerPinView
        return pinView
    }
    
    func markerView(_ addressText: String, _ color: UIColor) -> UIView {
        
        var addressView = MarkerAddressView()
        addressView = loadAddrNiB()
        let addressViewWidth = addressView.frame.width
        let addressViewHeight = addressView.frame.height
        
        var pinView = MarkerPinView()
        pinView = loadPinNiB()
        let pinViewWidth = pinView.frame.width
        let pinViewHeight = pinView.frame.height
        
        let padding: CGFloat = 10.0
        
        markerViewDimensions.width = 2 * addressViewWidth + pinViewWidth + padding
        markerViewDimensions.height = 2 * addressViewHeight + pinViewHeight + padding
        
        let backView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: markerViewDimensions.width, height: markerViewDimensions.height))
        addressView.frame = CGRect(x: 0.0, y: 0.0, width: addressViewWidth, height: addressViewHeight)
//        let pinView = UIView(frame: CGRect(x: backViewWidht/2 - 15, y: backViewHeight/2 - 15, width: 30, height: 30))
//        pinView.clipsToBounds = true
        pinView.frame = CGRect(x: markerViewDimensions.width/2 - pinViewWidth/2, y: markerViewDimensions.height/2 - pinViewHeight/2, width: pinViewWidth, height: pinViewHeight)
        
//        addressView.alpha = 0.9
        addressView.layer.cornerRadius = 12
        addressView.layer.borderWidth = 2
//        addressView.layer.borderColor = UIColor.green.cgColor
        addressView.backgroundColor = color
        addressView.addressLabel.text = addressText
        addressView.tag = 2
        backView.addSubview(addressView)
        
        pinView.backgroundColor = color
        pinView.layer.cornerRadius = 15
        pinView.layer.borderWidth = 2
        pinView.tag = 1
        backView.addSubview(pinView)
//        backView.backgroundColor = UIColor.red
//        backView.alpha = 0.5
        return backView
    }
    
    func frameOutOfScreenBounds(_ frame: CGRect) -> Bool {
        
        if self.view.frame.contains(frame) {
            return false
        } else {
            return true
        }
    }
    
    func framesIntersect(_ firstFrame: CGRect, _ secondFrame: CGRect) -> Bool {
        
        guard firstFrame != CGRect.zero, secondFrame != CGRect.zero else {
            return false
        }
        
        return firstFrame.intersects(secondFrame)
    }
    
    func getRespectiveAddressViewFrame(_ mapView: GMSMapView, forMarker marker: GMSMarker) -> CGRect {
        
        guard let iconView = marker.iconView, let addressViewFrame = iconView.subviews.first?.frame else {
            return CGRect.zero
        }
        
        let markerCenterPoint = mapView.projection.point(for: marker.position)
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        switch (addressViewFrame.origin.x, addressViewFrame.origin.y) {
        case (0, 0):
            offsetX -= markerViewDimensions.width/2
            offsetY -= markerViewDimensions.height/2
        case (markerViewDimensions.width - addressViewFrame.width, 0):
            offsetX = markerViewDimensions.width/2 - addressViewFrame.width
            offsetY -= markerViewDimensions.height/2
        case (0, markerViewDimensions.height - addressViewFrame.height):
            offsetX -= markerViewDimensions.width/2
            offsetY = markerViewDimensions.height/2 - addressViewFrame.height
        case (markerViewDimensions.width - addressViewFrame.width, markerViewDimensions.height - addressViewFrame.height):
            offsetX = markerViewDimensions.width/2 - addressViewFrame.width
            offsetY = markerViewDimensions.height/2 - addressViewFrame.height
        default:
            break
        }
        
        let addressViewOriginX = markerCenterPoint.x + offsetX
        let addressViewOriginY = markerCenterPoint.y + offsetY
        
        return CGRect(x: addressViewOriginX, y: addressViewOriginY, width: addressViewFrame.width, height: addressViewFrame.height)
    }
    
    func getFutureAddressViewFrame(for currentFrame: CGRect, _ currentPosition: Position, _ newPosition: Position) -> CGRect {
        
        var backViewOrigin: CGPoint = CGPoint.zero
        var newFrame: CGRect = CGRect.zero
        
        // Find back view respective position to super view
        switch currentPosition {
        case .topLeft:
            backViewOrigin.x = currentFrame.origin.x
            backViewOrigin.y = currentFrame.origin.y
        case .topRight:
            backViewOrigin.x = currentFrame.origin.x - (markerViewDimensions.width - currentFrame.width)
            backViewOrigin.y = currentFrame.origin.y
        case .bottomLeft:
            backViewOrigin.x = currentFrame.origin.x
            backViewOrigin.y = currentFrame.origin.y - (markerViewDimensions.height - currentFrame.height)
        case .bottomRight:
            backViewOrigin.x = currentFrame.origin.x - (markerViewDimensions.width - currentFrame.width)
            backViewOrigin.y = currentFrame.origin.y - (markerViewDimensions.height - currentFrame.height)
        }
        
        // Find new position respective frame
        switch newPosition {
        case .topLeft:
            newFrame = CGRect(x: backViewOrigin.x, y: backViewOrigin.y, width: currentFrame.width, height: currentFrame.height)
        case .topRight:
            newFrame = CGRect(x: backViewOrigin.x + (markerViewDimensions.width - currentFrame.width), y: backViewOrigin.y, width: currentFrame.width, height: currentFrame.height)
        case .bottomLeft:
            newFrame = CGRect(x: backViewOrigin.x, y: backViewOrigin.y + (markerViewDimensions.height - currentFrame.height), width: currentFrame.width, height: currentFrame.height)
        case .bottomRight:
            newFrame = CGRect(x: backViewOrigin.x + (markerViewDimensions.width - currentFrame.width), y: backViewOrigin.y + (markerViewDimensions.height - currentFrame.height), width: currentFrame.width, height: currentFrame.height)
        }
        
        return newFrame
    }
    
    func getRespectivePinFrame(_ mapView: GMSMapView, forMarker marker: GMSMarker) -> CGRect {
    
        guard let iconView = marker.iconView else {
            return CGRect.zero
        }
    
        let markerCenterPoint = mapView.projection.point(for: marker.position)
        let pinFrame = iconView.subviews[1].frame

        return CGRect(x: markerCenterPoint.x - pinFrame.width/2, y: markerCenterPoint.y - pinFrame.height/2, width: pinFrame.width, height: pinFrame.height)
    }
    
    func animateAddressViewsIfNeeded(_ mapView: GMSMapView) {
        
        var pickupAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: pickup)
        var dropoffAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: dropoff)
        let pickupPinFrame = getRespectivePinFrame(mapView, forMarker: pickup)
        let dropoffPinFrame = getRespectivePinFrame(mapView, forMarker: dropoff)
        
        var currentPickupAddrPosition: Position = pickupAddrPosition
        var currentDropoffAddrPosition: Position = dropoffAddrPosition
        
        if shouldAnimateAddressViews(pickupAddrFrame, pickupPinFrame, dropoffAddrFrame, dropoffPinFrame) {
            outerLoop: for newPickupAddrPosition in positionsArray {
                pickupAddrFrame = getFutureAddressViewFrame(for: pickupAddrFrame, currentPickupAddrPosition, newPickupAddrPosition)
                currentPickupAddrPosition = newPickupAddrPosition
                for newDropoffAddrPosition in positionsArray {
                    dropoffAddrFrame = getFutureAddressViewFrame(for: dropoffAddrFrame, currentDropoffAddrPosition, newDropoffAddrPosition)
                    currentDropoffAddrPosition = newDropoffAddrPosition
                    if !shouldAnimateAddressViews(pickupAddrFrame, pickupPinFrame, dropoffAddrFrame, dropoffPinFrame) {
                        animateAddressTo(newPickupAddrPosition, pickupAddrFrame, pickup)
                        animateAddressTo(newDropoffAddrPosition, dropoffAddrFrame, dropoff)
                        pickupAddrPosition = newPickupAddrPosition
                        dropoffAddrPosition = newDropoffAddrPosition
                        break outerLoop
                    }
                }
            }
        }
    }
    
    func shouldAnimateAddressViews(_ pickupAddrFrame: CGRect, _ pickupPinFrame: CGRect,
                                   _ dropoffAddrFrame: CGRect, _ dropoffPinFrame: CGRect) -> Bool {
        
        if framesIntersect(pickupPinFrame, dropoffAddrFrame) ||
            framesIntersect(dropoffPinFrame, pickupAddrFrame) ||
            framesIntersect(pickupAddrFrame, dropoffAddrFrame) {
            
            return true
        }
        
        if frameOutOfScreenBounds(pickupAddrFrame) || frameOutOfScreenBounds(dropoffAddrFrame) {
            return true
        }
        
        return false
    }
    
    func animateAddressTo(_ position: Position, _ frame: CGRect, _ marker: GMSMarker) {
        
        let point = position.positionCoordinates(for: frame, dimensions: markerViewDimensions)
        
        if let backView = marker.iconView {
            let subViews = backView.subviews
            for view in subViews {
                if view.tag == 2 {
                    UIView.animate(withDuration: 0.5, animations: {
                        view.frame = CGRect(x: point.x, y: point.y, width: view.frame.width, height: view.frame.height)
                    })
                }
            }
        }
    }
}

extension CustomMarkerVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        animateAddressViewsIfNeeded(mapView)
    }
}
