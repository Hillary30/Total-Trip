//
//  ContentView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//    
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import MapKit
import URLImage
 
extension UIColor {
    convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}

var dark_blue = Color(red: 25/255, green: 49/255, blue: 133/255)
var flower_yellow = Color(red: 244/255, green: 202/255, blue: 115/255)
var gold_yellow = Color(red: 237/255, green: 167/255, blue: 29/255)



struct ContentView: View {
    @State private var selectedTab = 0
    @State var upcomingvacations: [Vacation]
    @State var pastvacations: [Vacation]
    @State var favoriteRestaurants = [Restaurant]()
    @State var favoriteEvents = [Event]()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeView(favoriteRestaurant: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, pastvacations: $pastvacations)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                FavoritesView(favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents)
            }
            .tabItem {
                Label("Favorites", systemImage: "star")
            }
            .tag(1)
        }
        .accentColor(gold_yellow)
    }
}

struct HomeView: View {
    @State private var selectedSegment = 0
    @State private var showRecTrips = false
    @Binding var favoriteRestaurant: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @Binding var pastvacations: [Vacation]
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Total Trip")
                .font(.title)
                .fontWeight(.medium)
                .foregroundColor(Color.white)
                .padding(.top)
            HStack {
                Picker(selection: $selectedSegment, label: Text("")) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                NavigationLink(destination: ChooseLocationView(favoriteRestaurants: $favoriteRestaurant, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                }
                .buttonStyle(MyCustomButtonStyle())
                .padding(.trailing)
            }
            
            if selectedSegment == 0 {
                if upcomingvacations.isEmpty {
                    Rectangle()
                        .fill(Color.white)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            Text("Click on the + to add a trip!")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                                .background(flower_yellow)
                                .cornerRadius(10)
                        )
                }
                else {
                    List(upcomingvacations) { vacation in //list the upcoming vacations
                        NavigationLink(destination: ExistingOptionDetailsView(vacation: vacation, favoriteRestaurants: $favoriteRestaurant, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, pastvacations: $pastvacations)) {
                            Text(vacation.destination)
                        }
                    }
                }
            } else {
                if pastvacations.isEmpty {
                    Rectangle()
                        .fill(Color.white)
                        .edgesIgnoringSafeArea(.all)
                        
                }
                else {
                    List(pastvacations) { vacation in
                        NavigationLink(destination: ExistingOptionDetailsView(vacation: vacation, favoriteRestaurants: $favoriteRestaurant, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations, pastvacations: $pastvacations)) {
                            Text(vacation.destination)
                        }
                    }
                }
            }
        }
        .background(dark_blue)
        
    }
}
    
struct MyCustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(Color.white) // Set the background color to white
            .foregroundColor(gold_yellow) // Set the text color
            .cornerRadius(8) // Add corner radius if desired
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white, lineWidth: 2) // Add border color    and width
            )
    }
}


struct FavoritesView: View { //redo this
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var allItems: [AnyHashable] {
        (favoriteEvents.map { $0 as AnyHashable } + favoriteRestaurants.map { $0 as AnyHashable })
    }
    
    var body: some View {
        VStack {
            if HeightSizeClass == .regular {
                Rectangle()
                    .fill(dark_blue)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: 70)
                    .overlay(
                        Text("Favorites")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                    )
                Spacer()
            }
            if HeightSizeClass == .compact {
                Rectangle()
                    .fill(dark_blue)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: 65)
                    .overlay(
                        Text("Favorites")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(Color.white)
                            .padding()
                    )
                Spacer()
            }
            ForEach(allItems, id: \.self) { item in
                if let event = item as? Event {
                    NavigationLink(destination: ExistingEventDetails(selectedEvent: event)) {
                        Text("\(event.name ?? "")")
                    }
                } else if let restaurant = item as? Restaurant {
                    NavigationLink(destination: ExistingBusinessDetails(selectedRestaurant: restaurant)) {
                        Text("\(restaurant.name)")
                    }
                }
                Divider()
            }
            Spacer()
        }
    }
}

struct ExistingOptionDetailsView: View { //viwe to see a vacation already added
    var vacation: Vacation
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    @Binding var pastvacations: [Vacation]
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
            
            Text("\(vacation.destination)")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding()
             
            NavigationLink(destination: ExistingItinerary(vacation: vacation, favoriteRestaurants:  $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)) {
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
             
            NavigationLink(destination: ExistingHotel(upcomingvacations: $upcomingvacations, vacation: vacation)) {
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
            
            //button to remove the itinerary and add to past itinerary
            HStack {
                if let index = upcomingvacations.firstIndex(where: { $0.destination == "\(vacation.destination)" }) {
                    
                    Button(action: {
                        pastvacations.append(upcomingvacations[index ])
                        upcomingvacations.remove(at: index )
                    }) {
                        Text("Finish Itinerary")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .frame(minWidth: 100, maxWidth: .infinity)
                            .frame(height: 40) // Adjust the height as needed
                            .foregroundColor(.white)
                            .background(flower_yellow)
                            .cornerRadius(10)
                            .padding([.leading, .trailing, .bottom])
                    }
                    Button(action: {
                        upcomingvacations.remove(at: index )
                    }) {
                        Text("Delete Itinerary")
                            .font(.system(size: 17))
                            .fontWeight(.bold)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 40) // Adjust the height as needed
                            .foregroundColor(.white)
                            .background(flower_yellow)
                            .cornerRadius(10)
                            .padding([.leading, .trailing, .bottom])
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(upcomingvacations: UpcomingVacations, pastvacations: PastVacations, favoriteRestaurants: [], favoriteEvents: [])
    }
}
