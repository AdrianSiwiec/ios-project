//
//  ContentView.swift
//  PlacesToGo
//
//  Created by Admin on 30.01.2020.
//  Copyright © 2020 Adrian. All rights reserved.
//

import MapKit
import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var shouldUpdateMapViewLocation = false
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var pointsOnLine = [[CLLocationCoordinate2D]]()
    @State private var shouldCapturePoints = false
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    @State private var isUnlocked = true
    @State private var deviceLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var myLocationDelegate = MyCLLocationManagerDelegate()
    
    var body: some View {
        let mapView = MapView(centerCoordinate: $centerCoordinate, shouldUpdate: $shouldUpdateMapViewLocation, selectedPlace: $selectedPlace,
            showingPlaceDetails: $showingPlaceDetails, pointsOnLine: $pointsOnLine,
            annotations: locations)
        
        self.myLocationDelegate.setBinding(deviceLocation: $deviceLocation, pointsOnLine: $pointsOnLine, shouldCapturePoints: $shouldCapturePoints)
        
        self.locationManager.delegate = self.myLocationDelegate
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        return ZStack {
            if isUnlocked {
                mapView.edgesIgnoringSafeArea(.all)
                Circle().fill(Color.blue).opacity(0.3).frame(width:32, height: 32)
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        Button( action: {
                            if self.deviceLocation != nil {
                                self.centerCoordinate = self.deviceLocation!
                                self.shouldUpdateMapViewLocation = true
                            } else {
                                print("Location coords are nil!")
                            }
                        }) {
                            Image(systemName: "location.fill")
                        }.padding()
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.title)
                            .clipShape(Circle())
                            .padding(.trailing)
                        
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            let newLocation = CodableMKPointAnnotation()
                            newLocation.title = NSLocalizedString("Default title", comment: "")
                            newLocation.subtitle = NSLocalizedString("Default subtitle", comment: "")
                            newLocation.coordinate = self.centerCoordinate
                            self.locations.append(newLocation)
                            
                            self.selectedPlace = newLocation
                            self.showingEditScreen = true
                        }) {
                            Image(systemName: "plus")
                        }.padding()
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.title)
                            .clipShape(Circle())
                            .padding(.trailing)
                    }
                    HStack{
                        Spacer()
                        Button( action: {
                            if !self.shouldCapturePoints {
                                self.pointsOnLine.append([CLLocationCoordinate2D]())
                            }
                            self.shouldCapturePoints = true
                        }) {
                            Image(systemName: "play.fill")
                        }.padding()
                            .background(Color.green.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.title)
                            .clipShape(Circle())
                            .padding(.trailing)
                        Button( action: {
                            self.shouldCapturePoints = false
                        }) {
                            Image(systemName: "stop.fill")
                        }.padding()
                            .background(Color.red.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.title)
                            .clipShape(Circle())
                            .padding(.trailing)
                        Spacer()
                    }
                }
            } else {
                Button("Unlock Places") {
                    self.authenticate()
                }
            .padding()
                .background(Color.blue)
                .foregroundColor(.white)
            .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showingPlaceDetails) {
            Alert( title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place information."), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                    self.showingEditScreen = true
                })
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
    .onAppear(perform: loadData)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
            print("Loaded data")
        } catch {
            print("Unexpected error: \(error).")
            print("Unable to load saved data")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            print("Saved data")
        } catch {
            print("Unable to save data")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate yourself to unlock your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, authenticationError in DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        print("Failure in authentication!")
                    }
                }
            }
        } else {
            print("Authentication not supported!")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
