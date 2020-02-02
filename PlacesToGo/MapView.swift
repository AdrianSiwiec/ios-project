//
//  MapView.swift
//  PlacesToGo
//
//  Created by Admin on 30.01.2020.
//  Copyright © 2020 Adrian. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var shouldUpdate: Bool
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var pointsOnLine: [[CLLocationCoordinate2D]]
    
    var annotations: [MKPointAnnotation]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
        
        if shouldUpdate {
            view.setCenter(centerCoordinate, animated: true)
        }
        
        pointsOnLine.forEach { (points) in
            let polyline = MKPolyline(coordinates: points, count: points.count)
            view.addOverlay(polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
            parent.centerCoordinate = mapView.centerCoordinate
            parent.shouldUpdate = false
        }
        
    
        
        func mapView(_ mapView: MKMapView, viewFor annotation:MKAnnotation) -> MKAnnotationView? {
            let identifier = "Placemark"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            parent.selectedPlace = placemark
            parent.showingPlaceDetails = true
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay.isKind(of: MKPolyline.self) {
                // draw the track
                let polyLine = overlay
                let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
                polyLineRenderer.strokeColor = UIColor.red
                polyLineRenderer.lineWidth = 1.0
            
                return polyLineRenderer
            }
            return MKPolylineRenderer()
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "Krakow"
        annotation.subtitle = "Where the home is."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.0647, longitude: 19.9450)
        
        return annotation
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate),
                shouldUpdate: .constant(false),
                selectedPlace: .constant(MKPointAnnotation.example),
                showingPlaceDetails: .constant(false),
                pointsOnLine: .constant([[CLLocationCoordinate2D]]()),
                annotations: [MKPointAnnotation.example])
    }
}
