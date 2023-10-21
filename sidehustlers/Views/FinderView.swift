//
//  FinderView.swift
//  sidehustlers
//
//  Created by Robert Falkbäck on 2023-10-14.
//

import SwiftUI
import MapKit

struct FinderView: View {
    @Binding var selectedTab: Int
    @State private var coordinates: CLLocationCoordinate2D?
    @State private var coordinatesRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686), // Coordinates for Stockholm, Sweden
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
   

    // A function to add a map annotation
    func addAnnotation(title: String, coordinate: CLLocationCoordinate2D) {
        let newAnnotation = MapAnnotation(coordinate: coordinate) {
            VStack {
                Text(title)
            }
        }
      
    }

    // A function to perform geocoding
    func geocodeLocation() {
        let locationName = "Stockholm, Sweden"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self.coordinates = location.coordinate
                self.coordinatesRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )

                // Add a map annotation to the map at Stockholm's coordinates
                addAnnotation(title: "Stockholm, Sweden", coordinate: location.coordinate)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Find Side Hustles")
                
                // Button to trigger geocoding
                Button("Reset") {
                    geocodeLocation()
                }

                Map(coordinateRegion: $coordinatesRegion, showsUserLocation: true)
                Spacer()
            }
        }
    }
}
