//
//  ContentView.swift
//  PlacesToGo
//
//  Created by Admin on 30.01.2020.
//  Copyright © 2020 Adrian. All rights reserved.
//

import MapKit
import SwiftUI

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    var body: some View {
        ZStack {
            MapView(centerCoordinate: $centerCoordinate)
                .edgesIgnoringSafeArea(.all)
            Circle().fill(Color.blue).opacity(0.3).frame(width:3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
