//
//  ItineraryView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI

struct ExistingItinerary: View { //list of activities for itinerary already added
    var vacation: Vacation
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?

    var allItems: [AnyHashable] {
        (vacation.eventActivities.map { $0 as AnyHashable } + vacation.restaurantActivities.map { $0 as AnyHashable })
            .sorted { (item1, item2) -> Bool in
                if let date1 = (item1 as? Event)?.date ?? (item1 as? Restaurant)?.date,
                   let date2 = (item2 as? Event)?.date ?? (item2 as? Restaurant)?.date {
                    return date1 < date2
                }
                return false
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
        
        VStack {
            Text("Itinerary for \(vacation.destination)")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding()
            
            if vacation.eventActivities.isEmpty && vacation.restaurantActivities.isEmpty {
                Text("No Activities in Itinerary")
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
        
        Spacer()
        
        HStack {
            Spacer()
            VStack {
                Spacer()
                NavigationLink(destination: AddItinerary(vacation: vacation, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)) {
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
}

struct AddItinerary: View { //add activities to itinerary
    @State private var showRestaurantList = false
    @State private var showEventList = false
    var vacation: Vacation
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    var types_of_businesses: [String] = ["restaurants", "shopping"]
    var types_of_events: [String] = ["festivals-fairs", "nightlife", "music", "visual-arts", "food-and-drink", "film", "charities"]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack {
                Text("Businesses")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    //.padding()
                
                ForEach(types_of_businesses, id: \.self) { businessType in
                    NavigationLink(destination: BusinessList(selectedLocation: vacation.destination, favoriteRestaurants: $favoriteRestaurants, upcomingvacations: $upcomingvacations, favoriteEvents: $favoriteEvents, business_type: "\(businessType)")) {
                        Text("\(businessType)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: 200)
                            .frame(height: 50) // Adjust the height as needed
                            .foregroundColor(.white)
                            .background(flower_yellow)
                            .cornerRadius(10)
                            .padding([.leading, .trailing])
                    }
                }
                Spacer()
                
                Text("Events")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    //.padding()
                ForEach(types_of_events, id: \.self) {eventType in
                    NavigationLink(destination: EventList(selectedLocation: vacation.destination, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, category: "\(eventType)", favoriteRestaurants: $favoriteRestaurants)) {
                        Text("\(eventType)")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: 200)
                            .frame(height: 50) // Adjust the height as needed
                            .foregroundColor(.white)
                            .background(flower_yellow)
                            .cornerRadius(10)
                            .padding([.leading, .trailing])
                    }
                }
                Spacer()
            }
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
            HStack {
                VStack {
                    Text("Businesses")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                    //.padding()
                    
                    ForEach(types_of_businesses, id: \.self) { businessType in
                        NavigationLink(destination: BusinessList(selectedLocation: vacation.destination, favoriteRestaurants: $favoriteRestaurants, upcomingvacations: $upcomingvacations, favoriteEvents: $favoriteEvents, business_type: "\(businessType)")) {
                            Text("\(businessType)")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .frame(minWidth: 0, maxWidth: 200)
                                .frame(height: 50) // Adjust the height as needed
                                .foregroundColor(.white)
                                .background(flower_yellow)
                                .cornerRadius(10)
                                .padding([.leading, .trailing])
                        }
                    }
                }
                Spacer()
                    .frame(width: 100)
                VStack {
                    Text("Events")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(types_of_events, id: \.self) {eventType in
                            NavigationLink(destination: EventList(selectedLocation: vacation.destination, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, category: "\(eventType)", favoriteRestaurants: $favoriteRestaurants)) {
                                Text("\(eventType)")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .frame(minWidth: 0, maxWidth: 200)
                                    .frame(height: 50) // Adjust the height as needed
                                    .foregroundColor(.white)
                                    .background(flower_yellow)
                                    .cornerRadius(10)
                                    .padding([.leading, .trailing])
                            }
                        }
                    }
                }
            }
        }
        
    }
}

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()



