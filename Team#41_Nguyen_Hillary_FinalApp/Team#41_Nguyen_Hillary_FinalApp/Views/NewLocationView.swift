//
//  NewLocationView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine
import URLImage

struct ChooseLocationView: View { //see the diff locations to chose from
    let RecLocations = ["Japan", "Spain", "Australia", "Italy","Hanoi", "Paris"]
    let NewLocations = ["Germany", "Greece", "Beijing", "India", "Bangkok", "Jakarta"]
    let PopularLocations = ["Mexico", "Sweden", "Morocco", "London", "Prague"]
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @State var newVacation: Vacation = Vacation(destination: "")
    @State private var userInput: String = ""
    @State private var isNavigationActive: Bool = false
    @ObservedObject var searchObjectController = SearchObjectController.shared

    var body: some View {
        HStack {
            TextField("Enter city or country", text: $userInput) //user input location
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(height: 50)
                .padding()
            
            NavigationLink(
                destination: AddOptionDetailsView(selectedLocation: userInput, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, newVacation: $newVacation, userInput: $userInput),
                isActive: $isNavigationActive,
                label: {
                    ZStack {
                        Rectangle()
                            .stroke(flower_yellow, lineWidth: 5)
                            .cornerRadius(5)
                            .frame(width: 60, height: 35)

                        Text("Enter")
                            .fontWeight(.bold)
                            .frame(width: 55, height: 30)
                            .foregroundColor(.white)
                            .background(dark_blue)
                    }
                }
            )
            .disabled(userInput.isEmpty)
            .padding(.trailing)
        }
        .background(dark_blue.edgesIgnoringSafeArea(.all))
        .padding(.bottom)
        
        ScrollView(.vertical, showsIndicators: false) {
            HStack {
                Text("Recomendations")
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding(.leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(RecLocations, id: \.self) { location in
                        NavigationLink(destination: AddOptionDetailsView(selectedLocation: location, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, newVacation: $newVacation, userInput: $userInput)){
                            VStack {
                                if let imageURL = searchObjectController.imageURL(for: location) {
                                    VStack {
                                        URLImage(URL(string: imageURL)!) { image in
                                            image
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        }
                                        Text("\(location)")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.black.opacity(0.7))
                                            )
                                            .cornerRadius(10)
                                            .offset(x: -25,y: -70)
                                    }
                                } else {
                                }
                            }
                            .onAppear() {
                                searchObjectController.search(for: location)
                            }
                        }
                    }
                }
                .padding(.leading)
            }
            
            HStack {
                Text("New Places")
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(NewLocations, id: \.self) { location in
                        NavigationLink(destination: AddOptionDetailsView(selectedLocation: location, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, newVacation: $newVacation, userInput: $userInput)){
                            VStack {
                                if let imageURL = searchObjectController.imageURL(for: location) {
                                    VStack {
                                        URLImage(URL(string: imageURL)!) { image in
                                            image
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        }
                                        Text("\(location)")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.black.opacity(0.7))
                                            )
                                            .cornerRadius(10)
                                            .offset(x: -25,y: -70)
                                    }
                                } else {
                                }
                            }
                            .onAppear() {
                                searchObjectController.search(for: location)
                            }
                        }
                    }
                }
                .padding(.leading)
            }
            
            HStack {
                Text("Popular Places")
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PopularLocations, id: \.self) { location in
                        NavigationLink(destination: AddOptionDetailsView(selectedLocation: location, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, newVacation: $newVacation, userInput: $userInput)){
                            VStack {
                                if let imageURL = searchObjectController.imageURL(for: location) {
                                    VStack {
                                        URLImage(URL(string: imageURL)!) { image in
                                            image
                                                .resizable()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                        }
                                        Text("\(location)")
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color.black.opacity(0.7))
                                            )
                                            .cornerRadius(10)
                                            .offset(x: -25,y: -70)
                                    }
                                } else {
                                }
                            }
                            .onAppear() {
                                searchObjectController.search(for: location)
                            }
                        }
                    }
                }
                .padding(.leading)
            }
        }
    }
}

struct AddOptionDetailsView: View { //2 option details for new itinerary (not added yet)
    var selectedLocation: String
    @State private var showItinerary = false
    @State private var showHotel = false
    @State private var showAirport = false
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @Binding var newVacation: Vacation
    @Binding var userInput: String
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        VStack {
            if HeightSizeClass == .regular {
                Rectangle()
                    .fill(dark_blue)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: 10)
            }
            if HeightSizeClass == .compact {
                Rectangle()
                    .fill(dark_blue)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: 15)
            }
            
            
            Text("\(selectedLocation)")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding()
            
            NavigationLink(destination: NewItinerary(selectedLocation: selectedLocation, newVacation: $newVacation, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)
                .onAppear {
                    newVacation.destination = selectedLocation
                    if userInput != "" {
                        newVacation.destination = userInput
                    }
                }
            ) {
                Text("Show Itinerary")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50) // Adjust the height as needed
                    .foregroundColor(.white)
                    .background(flower_yellow)
                    .cornerRadius(10)
                    .padding([.leading, .trailing, .bottom])
            }

            NavigationLink(destination: ExistingHotel(upcomingvacations: $upcomingvacations, vacation: newVacation)
                .onAppear {
                    newVacation.destination = selectedLocation
                    if userInput != "" {
                        newVacation.destination = userInput
                    }
                }
            ) {
                Text("Show Hotel")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50) // Adjust the height as needed
                    .foregroundColor(.white)
                    .background(flower_yellow)
                    .cornerRadius(10)
                    .padding([.leading, .trailing, .bottom])
            }
            
            Spacer()
        }
    }
}


struct NewItinerary: View { //show list of activities added for new itinerary
    var selectedLocation: String
    @Binding var newVacation: Vacation
    @State private var showAddItinerary = false
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var allItems: [AnyHashable] {
        if upcomingvacations.contains(where: { $0.destination == "\(newVacation.destination)" }) {
            return (upcomingvacations[upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" }) ?? 0].eventActivities.map { $0 as AnyHashable } + upcomingvacations[upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" }) ?? 0].restaurantActivities.map { $0 as AnyHashable })
                .sorted { (item1, item2) -> Bool in
                    if let date1 = (item1 as? Event)?.date ?? (item1 as? Restaurant)?.date,
                       let date2 = (item2 as? Event)?.date ?? (item2 as? Restaurant)?.date {
                        return date1 < date2
                    }
                    return false
                }
        } else {
            return []
        }
    }
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
        }
        
        let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
        
        VStack {
            if index == nil {
                VStack() {
                    Text("Itinerary for \(selectedLocation)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding()
                    if newVacation.eventActivities.isEmpty && newVacation.restaurantActivities.isEmpty {
                        Text("No Activities in Itinerary")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            else {
                VStack() {
                    Text("Itinerary for \(selectedLocation)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding()
                    if (upcomingvacations[index ?? 0].eventActivities.isEmpty && upcomingvacations[index ?? 0].restaurantActivities.isEmpty) {
                        Text("No Activities in Itinerary")
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                    }
                    ForEach(allItems, id: \.self) { item in
                        if let event = item as? Event {
                            NavigationLink(destination: ExistingEventDetails(selectedEvent: event)) {
                                if event.date == nil {
                                    Text("Event: \(event.name ?? "")")
                                }
                                else {
                                    VStack {
                                        HStack {
                                            Text("Date: \(event.date ?? Date() , formatter: dateFormatter)")
                                                .frame(width: 120, alignment: .center)
                                                .frame(height: 100)
                                            Rectangle()
                                                .frame(maxHeight: 120)
                                                .frame(width: 1, height: 55, alignment: .center)
                                                .foregroundColor(Color.black)
                                            Text("Event: \(event.name ?? "")")
                                                .frame(maxWidth: 200, alignment: .leading)
                                                .frame(maxHeight: 100)
                                        }
                                        HStack {
                                            Spacer()
                                                .frame(width: 120, alignment: .center)
                                                .frame(height: 100)
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 20, height: 20)
                                                .frame(width: 1, height: 55, alignment: .center)
                                                .foregroundColor(Color.black)
                                            Spacer()
                                                .frame(maxWidth: 200, alignment: .leading)
                                                .frame(maxHeight: 100)
                                        }.padding(-70)
                                    }
                                    .padding(-20)
                                }
                            }
                        } else if let restaurant = item as? Restaurant {
                            NavigationLink(destination: ExistingBusinessDetails(selectedRestaurant: restaurant)) {
                                if restaurant.date == nil {
                                    Text("Restaurant: \(restaurant.name)")
                                }
                                else {
                                    VStack {
                                        HStack {
                                            Text("Date: \(restaurant.date ?? Date(), formatter: dateFormatter)")
                                                .frame(width: 120, alignment: .center)
                                                .frame(height: 100)
                                            Rectangle()
                                                .frame(maxHeight: 120)
                                                .frame(width: 1, height: 55, alignment: .center)
                                                .foregroundColor(Color.black)
                                            Text("Restaurant: \(restaurant.name)")
                                                .frame(maxWidth: 200, alignment: .leading)
                                                .frame(maxHeight: 100)
                                        }
                                        HStack {
                                            Spacer()
                                                .frame(width: 120, alignment: .center)
                                                .frame(height: 100)
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 20, height: 20)
                                                .frame(width: 1, height: 55, alignment: .center)
                                                .foregroundColor(Color.black)
                                            Spacer()
                                                .frame(maxWidth: 200, alignment: .leading)
                                                .frame(maxHeight: 100)
                                        }.padding(-70)
                                    }.padding(-20)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        
        Spacer()
    
        HStack {
            Spacer()
            
            VStack {
                NavigationLink(destination: AddItinerary(vacation: newVacation, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 30))
                        .padding(.bottom)
                }
                NavigationLink(destination: MapViewContainer(upcomingvacations: $upcomingvacations)) {
                    Image(systemName: "map")
                        .font(.system(size: 30))
                        .padding(.bottom)
                }
            }
            .padding()
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    func containsDestination(_ destination: String) -> Bool {
        return upcomingvacations.contains { $0.destination == destination }
    }
}



