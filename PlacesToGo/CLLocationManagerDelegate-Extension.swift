//
//  CLLocationManagerDelegate-Extension.swift
//  PlacesToGo
//
//  Created by Admin on 31.01.2020.
//  Copyright © 2020 Adrian. All rights reserved.
//

import MapKit
import SwiftUI

class MyCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    @Binding var deviceLocation: CLLocationCoordinate2D?
    
    override init() {
        self._deviceLocation = Binding.constant(nil)
        super.init()
    }
    
    func setBinding(deviceLocation: Binding<CLLocationCoordinate2D?>) {
        self._deviceLocation = deviceLocation
    }

    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Updated - this is my own delegate speaking!")
        print(locations)
        
        if !locations.isEmpty {
            self.deviceLocation = locations[0].coordinate
        }
        
//        if let location = locations.last{
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
//            self.map.setRegion(region, animated: true)
//        }
    }
}
