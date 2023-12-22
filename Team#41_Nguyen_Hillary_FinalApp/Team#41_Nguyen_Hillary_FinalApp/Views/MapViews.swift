//
//  MapViews.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import MapKit
import CoreLocation

//maps for events, restaurants, and full itinerary
struct MapView: UIViewRepresentable {
    var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Location"
        uiView.addAnnotation(annotation)
    }

}

struct AllLocationMapView: UIViewRepresentable {
    @Binding var vacations: [Vacation]

    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Remove existing annotations
        uiView.annotations.forEach { uiView.removeAnnotation($0) }

        // Add new annotations
        for vacation in vacations {
            for restaurant in vacation.restaurantActivities {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude)
                annotation.title = restaurant.name
                uiView.addAnnotation(annotation)
            }
        }
        for vacation in vacations {
            for event in vacation.eventActivities {
                if (event.latitude != nil && event.longitude != nil) {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0)
                    annotation.title = event.name
                    uiView.addAnnotation(annotation)
                }
            }
        }

        // Set region based on the first vacation and its first restaurant coordinates
        if let firstVacation = vacations.first, let firstRestaurant = firstVacation.restaurantActivities.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: firstRestaurant.coordinates.latitude, longitude: firstRestaurant.coordinates.longitude), span: span)
            uiView.setRegion(region, animated: true)
        }
    }
}

struct MapViewContainer: View {
    @Binding var upcomingvacations: [Vacation]

    var body: some View {
        AllLocationMapView(vacations: $upcomingvacations)
            .edgesIgnoringSafeArea(.all)
    }
}


//get user location


