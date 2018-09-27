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

        // Create a GMSMapView and set it to view
        let camera = GMSCameraPosition.camera(withLatitude: 37.98591, longitude: 23.72983, zoom: 14.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.camera = camera
        mapView.delegate = self
        mapView.settings.rotateGestures = false
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        mapView.settings.tiltGestures = false
        self.view = mapView

        // Create custom pickup marker
        pickup.iconView = markerView("Sina 11")
        pickup.tracksViewChanges = true
        pickup.position = CLLocationCoordinate2D(latitude: 37.98591, longitude: 23.72983)
        pickup.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        pickup.map = mapView

        // Create custom dropoff marker
        dropoff.iconView = markerView("Mitropoleos 45")
        dropoff.position = CLLocationCoordinate2D(latitude: 37.96591, longitude: 23.73983)
        dropoff.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        dropoff.map = mapView
        
        // Set their default positions to top left
        pickupAddrPosition = .topLeft
        dropoffAddrPosition = .topLeft
    }
    
    /**
     Creates a custom view that will be used as the marker's iconView and sets its constraints
     
     - Parameter addressText: The text to be displayed in the address view
     
     - Returns: The view to be assigned on the marker's iconView
     */
    func markerView(_ addressText: String) -> UIView {
        
        let markerView = MarkerView(addressText)
        markerView.setupConstraints()

        return markerView
    }
    
    /**
     Checks if the view entirely contains the given frame
     
     - Parameter frame: The frame to check
     
     - Returns: True if the view contains the frame. False otherwise.
     */
    func frameOutOfBounds(_ frame: CGRect) -> Bool {
        
        if self.view.frame.contains(frame) {
            return false
        } else {
            return true
        }
    }
    
    /**
     Checks if two non-zero frames intersect
     
     - Parameters: The two frames to check
     
     - Returns: True if the two frames intersect. False otherwise
     */
    func framesIntersect(_ firstFrame: CGRect, _ secondFrame: CGRect) -> Bool {
        
        guard firstFrame != CGRect.zero, secondFrame != CGRect.zero else {
            return false
        }
        
        return firstFrame.intersects(secondFrame)
    }
    
    /**
     Calculates marker's addressView frame projected on screen coordinates
     
     - Parameter mapView: The GMSMapView that the projection will be applied on
     - Parameter marker: The GMSMarker whose addressView frame we need to project on screen coordinates
     
     - Returns: The marker's respective addressView frame
     */
    func getRespectiveAddressViewFrame(_ mapView: GMSMapView, forMarker marker: GMSMarker) -> CGRect {
        
        guard let iconView = marker.iconView, let addressViewFrame = iconView.subviews.first?.frame else {
            return CGRect.zero
        }
        
        // Get the center point of marker's iconView projected to screen coordinates
        let markerCenterPoint = mapView.projection.point(for: marker.position)
        let markerViewWidth = iconView.frame.width
        let markerViewHeight = iconView.frame.height
        
        var offsetX: CGFloat = 0.0
        var offsetY: CGFloat = 0.0
        
        let currentPosition: Position = marker == pickup ? pickupAddrPosition : dropoffAddrPosition
        
        // Based on marker's current position calculate the offsetX and offsetY from the center of the iconView
        // in order to locate the addressView frame coordinates
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
    
    /**
     Calculates marker's addressView frame on its future position
     
     - Parameter currentFrame: The current addressView frame on screen coordinates
     - Parameter currentPosition: The addressView current position
     - Parameter newPosition: The addressView future position
     - Parameter markerViewDimensions: The dimensions (width, height) of marker's iconView
     
     - Returns: Marker's respective addressView frame of the future position
     */
    func getFutureAddressViewFrame(for currentFrame: CGRect, _ currentPosition: Position, _ newPosition: Position, _ markerViewDimensions: (width: CGFloat, height: CGFloat)) -> CGRect {

        var backViewOrigin: CGPoint = CGPoint.zero
        var newFrame: CGRect = CGRect.zero
        
        // Based on current addressView position, find iconView (aka backView) origin coordinates
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
        
        // Find future position respective frame
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
    
    /**
     Calculates marker's pinView frame projected on screen coordinates
     
     - Parameter mapView: The GMSMapView that the projection will be applied on
     - Parameter marker: The GMSMarker whose pinView frame we need to project on screen coordinates
     
     - Returns: The marker's respective pinView frame
     */
    func getRespectivePinFrame(_ mapView: GMSMapView, forMarker marker: GMSMarker) -> CGRect {
    
        guard let iconView = marker.iconView else {
            return CGRect.zero
        }
    
        // Get the center point of marker's iconView projected to screen coordinates
        let markerCenterPoint = mapView.projection.point(for: marker.position)
        let pinFrame = iconView.subviews[1].frame

        return CGRect(x: markerCenterPoint.x - pinFrame.width/2, y: markerCenterPoint.y - pinFrame.height/2, width: pinFrame.width, height: pinFrame.height)
    }
    
    /**
     Checks if two different addressViews need to be animated based on some display criteria
     
     - Parameter mapView: The GMSMapView
     */
    func animateAddressViewsIfNeeded(_ mapView: GMSMapView) {
        
        guard let pickupIconView = pickup.iconView, let dropoffIconView = dropoff.iconView else {
            return
        }
        
        // Get the respective frames (on screen coordinates) for addressViews and pinViews
        // Will be used for intersection and out of bounds checks
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
        
        // Checks if addressViews and pinViews intersect or if addressView(s) is(are) out of screen (or container view) bounds
        if shouldAnimateAddressViews(tempPickupAddrFrame, pickupPinFrame, tempDropoffAddrFrame, dropoffPinFrame) {
            
            // Iterate every possible positions for both pickup and dropoff addressViews
            // If there is a position for each addressView that is intersection free and both addressViews are inside bounds, animate to these positions
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
            
            // If the perfect position doesn't exist and pickup addressView frame is out of screen (or container view) bounds
            // Check if there is a position for pickup addressView that is inside bounds and is intersection free, and animate to this position
            if frameOutOfBounds(pickupAddrFrame) {
                if let newAddrPosition = animateAddressViewIfPossible(for: pickup, pickupAddrFrame, dropoffAddrFrame,
                                                                      pickupAddrPosition, pickupViewDimensions) {
                    
                    pickupAddrPosition = newAddrPosition
                    pickupAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: pickup)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                    return
                }
            }

            // If the perfect position doesn't exist and dropoff addressView frame is out of screen (or container view) bounds
            // Check if there is a position for dropoff addressView that is inside bounds and is intersection free, and animate to this position
            if frameOutOfBounds(dropoffAddrFrame) {
                if let newAddrPosition = animateAddressViewIfPossible(for: dropoff, dropoffAddrFrame, pickupAddrFrame,
                                                                      dropoffAddrPosition, dropoffViewDimensions) {
                    
                    dropoffAddrPosition = newAddrPosition
                    dropoffAddrFrame = getRespectiveAddressViewFrame(mapView, forMarker: dropoff)
                    bringAddrViewToFrontIfNeeded(pickupPinFrame, pickupAddrFrame, dropoffPinFrame, dropoffAddrFrame)
                    return
                }
            }

            // If the two addresViews still intersect inside the mapView,
            // check if there is a position for an addressView that doesn't intersect with the other one and it's inside bounds
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
    
    /**
     Checks if a pinView frame of one marker intersects with the addressView frame of another marker and sets the markers' zIndex accordingly so that the addressView is always above pinView
     
     - Parameter pickupPinFrame: The frame of the pickup pinView
     - Parameter pickupAddrFrame: The frame of the pickup addressView
     - Parameter dropoffPinFrame: The frame of the dropoff pinView
     - Parameter dropoffAddrFrame: The frame of the dropoff addressView
     */
    func bringAddrViewToFrontIfNeeded(_ pickupPinFrame: CGRect, _ pickupAddrFrame: CGRect, _ dropoffPinFrame: CGRect, _ dropoffAddrFrame: CGRect) {
        if framesIntersect(pickupPinFrame, dropoffAddrFrame) {
            pickup.zIndex = .min
            dropoff.zIndex = .max
        } else if framesIntersect(dropoffPinFrame, pickupAddrFrame) {
            dropoff.zIndex = .min
            pickup.zIndex = .max
        }
    }
    
    /**
     Checks if the following criteria are met in order to animate the addressViews or not
     
     # Criteria
     - Two addressViews intersect
     - An addressView and a pinView intersect
     - An addressView is out of screen (or container view) bounds
     
     - Parameter pickupPinFrame: The frame of the pickup pinView
     - Parameter pickupAddrFrame: The frame of the pickup addressView
     - Parameter dropoffPinFrame: The frame of the dropoff pinView
     - Parameter dropoffAddrFrame: The frame of the dropoff addressView
     
     - Returns: True if one of the above criteria are met. False otherwise
     */
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
    
    /**
     Checks if there is a position for an addressView that's intersection free and inside screen (or container view) bounds
     
     - Parameter marker: The GMSMarker whose addressView will be investigated for possible positions
     - Parameter firstAddrFrame: The first addressView frame
     - Parameter secondAddrFrame: The second addressView frame
     - Parameter currentPosition: The marker's addressView current position
     - Parameter markerDimensions: The dimensions of the marker's iconView
     
     - Returns: The new addressView position if exists. Null otherwise
     */
    func animateAddressViewIfPossible(for marker: GMSMarker, _ firstAddrFrame: CGRect,
                                      _ secondAddrFrame: CGRect, _ currentPosition: Position,
                                      _ markerDimensions: (CGFloat, CGFloat)) -> Position? {
        
        var tempFirstAddrFrame = firstAddrFrame
        let tempSecondAddrFrame = secondAddrFrame
        var tempAddrPosition = currentPosition
        
        // Loop through available positions and check if there is one that's intersection free and inside the view (or container view) bounds
        // If such position exists, animate addressView frame to that position
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
    
    /**
     Animates marker's addressView frame to the new position
     
     - Parameter position: The position to animate the addressView frame to
     - Parameter frame: The addressView frame to animate
     - Parameter marker: The marker whose addressView will be animated
     */
    func animateAddressTo(_ position: Position, _ frame: CGRect, _ marker: GMSMarker) {
        
        guard let iconView = marker.iconView, let addressView = iconView.subviews.first else {
            return
        }
        
        let markerViewDimensions = (iconView.frame.width, iconView.frame.height)
        let point = position.positionCoordinates(for: frame, dimensions: markerViewDimensions)
        
        UIView.animate(withDuration: 0.5, animations: {
            addressView.frame = CGRect(x: point.x, y: point.y, width: addressView.frame.width, height: addressView.frame.height)
        }) { (_) in
            
        }
    }
}

// MARK: - GoogleMaps delegates

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
