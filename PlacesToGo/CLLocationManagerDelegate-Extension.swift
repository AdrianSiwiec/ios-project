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
    @Binding var pointsOnLine: [[CLLocationCoordinate2D]]
    @Binding var shouldCapturePoints: Bool
    var lastAdded: Date
    
    override init() {
        self._deviceLocation = Binding.constant(nil)
        self._pointsOnLine = Binding.constant([[CLLocationCoordinate2D]]())
        self._shouldCapturePoints = Binding.constant(false)
        
        self.lastAdded = Date()
        super.init()
    }
    
    func setBinding(deviceLocation: Binding<CLLocationCoordinate2D?>, pointsOnLine: Binding<[[CLLocationCoordinate2D]]>, shouldCapturePoints: Binding<Bool>) {
        self._deviceLocation = deviceLocation
        self._pointsOnLine = pointsOnLine
        self._shouldCapturePoints = shouldCapturePoints
    }

    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty {
            self.deviceLocation = locations[0].coordinate
            
            if shouldCapturePoints && !pointsOnLine.isEmpty {
                if pointsOnLine[pointsOnLine.count - 1].count == 0 || locations[0].timestamp.timeIntervalSince(lastAdded) > 15 {
                    print("Appending!")
                    pointsOnLine[pointsOnLine.count - 1].append(locations[0].coordinate)
                    lastAdded = locations[0].timestamp
                }
            }
        }
    }
}
