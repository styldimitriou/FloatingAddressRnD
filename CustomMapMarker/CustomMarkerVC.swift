//
//  CustomMarkerVC.swift
//  CustomMapMarker
//
//  Created by Stelios Dimitriou on 04/09/2018.
//  Copyright © 2018 Stelios Dimitriou. All rights reserved.
//

import UIKit
import GoogleMaps

class CustomMarkerVC: UIViewController {
    
    var positionsArray: [Position] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    var pickup: GMSMarker = GMSMarker()
    var dropoff: GMSMarker = GMSMarker()
    var pickupAddrPosition: Position!
    var dropoffAddrPosition: Position!

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

        // Creates pickup marker
        pickup.iconView = markerView("Sina 11")
        pickup.tracksViewChanges = true
        pickup.position = CLLocationCoordinate2D(latitude: 37.98591, longitude: 23.72983)
        pickup.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        pickup.map = mapView

        // Creates dropoff marker
        dropoff.iconView = markerView("Mitropoleos 45")
        dropoff.position = CLLocationCoordinate2D(latitude: 37.96591, longitude: 23.73983)
        dropoff.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        dropoff.map = mapView
        
        pickupAddrPosition = .topLeft
        dropoffAddrPosition = .topLeft
    }
    
    func markerView(_ addressText: String) -> UIView {
        
        let markerView = MarkerView(addressText)
        markerView.setupConstraints()
//        markerView.layoutIfNeeded()
        return markerView
    }
    
    func frameOutOfBounds(_ frame: CGRect) -> Bool {
        
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
        let markerViewWidth = iconView.frame.width
        let markerViewHeight = iconView.frame.height
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        let currentPosition: Position = marker == pickup ? pickupAddrPosition : dropoffAddrPosition
        
        switch currentPosition {
        case .topLeft:
            offsetX -= markerViewWidth/2
            offsetY -= markerViewHeight/2
        case .topRight:
            offsetX = markerViewWidth/2 - addressViewFrame.width
            offsetY -= markerViewHeight/2
        case .bottomLeft:
            offsetX -= markerViewWidth/2
            offsetY = markerViewHeight/2 - addressViewFrame.height
        case .bottomRight:
            offsetX = markerViewWidth/2 - addressViewFrame.width
            offsetY = markerViewHeight/2 - addressViewFrame.height
        }
        
        let addressViewOriginX = markerCenterPoint.x + offsetX
        let addressViewOriginY = markerCenterPoint.y + offsetY
        
        return CGRect(x: addressViewOriginX, y: addressViewOriginY, width: addressViewFrame.width, height: addressViewFrame.height)
    }
    
    func getFutureAddressViewFrame(for currentFrame: CGRect, _ currentPosition: Position, _ newPosition: Position, _ markerViewDimensions: (width: CGFloat, height: CGFloat)) -> CGRect {
        
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
        
        guard let pickupIconView = pickup.iconView, let dropoffIconView = dropoff.iconView else {
            return
        }
        
        var pickupAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: pickup)
        var dropoffAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: dropoff)
        let pickupPinFrame = getRespectivePinFrame(mapView, forMarker: pickup)
        let dropoffPinFrame = getRespectivePinFrame(mapView, forMarker: dropoff)
        
        let pickupViewDimensions = (pickupIconView.frame.width, pickupIconView.frame.height)
        let dropoffViewDimensions = (dropoffIconView.frame.width, dropoffIconView.frame.height)
        
        var tempPickupAddrPosition: Position = pickupAddrPosition
        var tempDropoffAddrPosition: Position = dropoffAddrPosition
        var tempPickupAddrFrame: CGRect = pickupAddrFrame
        var tempDropoffAddrFrame: CGRect = dropoffAddrFrame
        
        if shouldAnimateAddressViews(tempPickupAddrFrame, pickupPinFrame, tempDropoffAddrFrame, dropoffPinFrame) {
            
            for newPickupAddrPosition in positionsArray {
                
                tempPickupAddrFrame = getFutureAddressViewFrame(for: tempPickupAddrFrame, tempPickupAddrPosition, newPickupAddrPosition, pickupViewDimensions)
                tempPickupAddrPosition = newPickupAddrPosition
                
                for newDropoffAddrPosition in positionsArray {
                    
                    tempDropoffAddrFrame = getFutureAddressViewFrame(for: tempDropoffAddrFrame, tempDropoffAddrPosition, newDropoffAddrPosition, dropoffViewDimensions)
                    tempDropoffAddrPosition = newDropoffAddrPosition
                    
                    if !shouldAnimateAddressViews(tempPickupAddrFrame, pickupPinFrame, tempDropoffAddrFrame, dropoffPinFrame) {
                        animateAddressTo(newPickupAddrPosition, tempPickupAddrFrame, pickup)
                        animateAddressTo(newDropoffAddrPosition, tempDropoffAddrFrame, dropoff)
                        pickupAddrPosition = newPickupAddrPosition
                        dropoffAddrPosition = newDropoffAddrPosition
                        return
                    }
                }
            }
            
            if frameOutOfBounds(pickupAddrFrame) {
                if let newAddrPosition = animateAddressViewIfPossible(for: pickup, pickupAddrFrame, dropoffAddrFrame,
                                                                      pickupAddrPosition, pickupViewDimensions) {
                    
                    pickupAddrPosition = newAddrPosition
                    pickupAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: pickup)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                    return
                }
            }

            if frameOutOfBounds(dropoffAddrFrame) {
                if let newAddrPosition = animateAddressViewIfPossible(for: dropoff, dropoffAddrFrame, pickupAddrFrame,
                                                                      dropoffAddrPosition, dropoffViewDimensions) {
                    
                    dropoffAddrPosition = newAddrPosition
                    dropoffAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: dropoff)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                    return
                }
            }

            if framesIntersect(pickupAddrFrame, dropoffAddrFrame) {
                if let newAddrPosition = animateAddressViewIfPossible(for: pickup, pickupAddrFrame, dropoffAddrFrame,
                                                                      pickupAddrPosition, pickupViewDimensions) {
                    
                    pickupAddrPosition = newAddrPosition
                    pickupAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: pickup)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                }
                
                if let newAddrPosition = animateAddressViewIfPossible(for: dropoff, dropoffAddrFrame, pickupAddrFrame,
                                                                      dropoffAddrPosition, dropoffViewDimensions) {
                    
                    dropoffAddrPosition = newAddrPosition
                    dropoffAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: dropoff)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                }
            }
        }
    }
    
    func bringAddrViewToFrontIfNeeded(_ pickupPinFrame: CGRect, _ pickupAddrFrame: CGRect, _ dropoffPinFrame: CGRect, _ dropoffAddrFrame: CGRect) {
        if framesIntersect(pickupPinFrame, dropoffAddrFrame) {
            pickup.zIndex = .min
            dropoff.zIndex = .max
        } else if framesIntersect(dropoffPinFrame, pickupAddrFrame) {
            dropoff.zIndex = .min
            pickup.zIndex = .max
        }
    }
    
    func shouldAnimateAddressViews(_ pickupAddrFrame: CGRect, _ pickupPinFrame: CGRect,
                                   _ dropoffAddrFrame: CGRect, _ dropoffPinFrame: CGRect) -> Bool {
        
        if framesIntersect(pickupPinFrame, dropoffAddrFrame) ||
            framesIntersect(dropoffPinFrame, pickupAddrFrame) ||
            framesIntersect(pickupAddrFrame, dropoffAddrFrame) {
            
            return true
        }
        
        if frameOutOfBounds(pickupAddrFrame) || frameOutOfBounds(dropoffAddrFrame) {
            return true
        }
        
        return false
    }
    
    func animateAddressViewIfPossible(for marker: GMSMarker, _ firstAddrFrame: CGRect,
                                      _ secondAddrFrame: CGRect, _ currentPosition: Position,
                                      _ markerDimensions: (CGFloat, CGFloat)) -> Position? {
        
        var tempFirstAddrFrame = firstAddrFrame
        let tempSecondAddrFrame = secondAddrFrame
        var tempAddrPosition = currentPosition
        
        for newAddrPosition in positionsArray {
            tempFirstAddrFrame = getFutureAddressViewFrame(for: tempFirstAddrFrame, tempAddrPosition, newAddrPosition, markerDimensions)
            tempAddrPosition = newAddrPosition
            if !frameOutOfBounds(tempFirstAddrFrame) && !framesIntersect(tempFirstAddrFrame, tempSecondAddrFrame) {
                animateAddressTo(newAddrPosition, tempFirstAddrFrame, marker)
                return newAddrPosition
            }
        }
        return nil
    }
    
    func getAnimationFinalPosition(for currentPosition: Position, _ frame: CGRect) -> Position {
        
        let parentViewWidth = self.view.frame.width
        let parentViewHeight = self.view.frame.height
        var newPosition: Position = currentPosition
        
        if frame.origin.x < 0 && frame.origin.y < 0 {
            newPosition = .bottomRight
        } else if (frame.origin.x + frame.width) > parentViewWidth && frame.origin.y < 0 {
            newPosition = .bottomLeft
        } else if frame.origin.x < 0 && (frame.origin.y + frame.height) > parentViewHeight {
            newPosition = .topRight
        } else if (frame.origin.x + frame.width) > parentViewWidth && (frame.origin.y + frame.height) > parentViewHeight {
            newPosition = .topLeft
        } else if frame.origin.y < 0 {
            if currentPosition == .topLeft {
                newPosition = .bottomLeft
            } else if currentPosition == .topRight {
                newPosition = .bottomRight
            }
        } else if (frame.origin.y + frame.height) > parentViewHeight {
            if currentPosition == .bottomLeft {
                newPosition = .topLeft
            } else if currentPosition == .bottomRight {
                newPosition = .topRight
            }
        } else if frame.origin.x < 0 {
            if currentPosition == .topLeft {
                newPosition = .topRight
            } else if currentPosition == .bottomLeft {
                newPosition = .bottomRight
            }
        } else if (frame.origin.x + frame.width) > parentViewWidth {
            if currentPosition == .topRight {
                newPosition = .topLeft
            } else if currentPosition == .bottomRight {
                newPosition = .bottomLeft
            }
        }
        
        return newPosition
    }
    
    func animateAddressTo(_ position: Position, _ frame: CGRect, _ marker: GMSMarker) {
        
        guard let iconView = marker.iconView else {
            return
        }
        
        let markerViewDimensions = (iconView.frame.width, iconView.frame.height)
        
        let point = position.positionCoordinates(for: frame, dimensions: markerViewDimensions)
        
        if let backView = marker.iconView, let addressView = backView.subviews.first {
            UIView.animate(withDuration: 0.5, animations: {
                addressView.frame = CGRect(x: point.x, y: point.y, width: addressView.frame.width, height: addressView.frame.height)
            }) { (_) in
                
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
