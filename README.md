# Floating Addresses

`Floating Addresses` is an implementation of an animatable bubble arround a Google Maps marker.

### The Problem

Google Maps iOS SDK does provide the ability to add a marker on your map among with a so called `infoWindow` above that marker where you can display information regarding that place.
However, this `infoWindow` is **not** animatable. The user can move the map outside the screen (or the map container view), or zoom in/out the map so that some infoWindows may intersect. In such cases, you can't have a smooth animation of that info view on a more suitable position inside the visible map area.

### The Solution
We took advantage of the `iconView` property of the GMSMarker, created a custom UIView (`MarkerView`) that is acting as our custom marker and assigned it to this property.
Our `MarkerView` consists of two subviews, an `addressView` which acts as GMSMarker's infoWindow and a `pinView` which acts (only visually) as a map marker.
So, when one of our addressViews is either outside the visible map area or intersects with another one, we animate the `addressView` to a more suitable position arround the `pinView`. 

![](/floating_addresses.gif)

## Getting Started

### Prerequisites

- Xcode 10+
- Swift 4.2
- iOS 11.4 and above

### Installing

Just clone this repo and run ```pod install```

## Authors

**Stelios Dimitriou** - *iOS Developer*

