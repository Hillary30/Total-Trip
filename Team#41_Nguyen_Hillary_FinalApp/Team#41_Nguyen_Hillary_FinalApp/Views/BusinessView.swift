//
//  BusinessView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import MapKit
import URLImage

struct BusinessList: View { //list of businesses
    @State var selectedLocation: String
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var restaurants = [Restaurant]()
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var upcomingvacations: [Vacation]
    @Binding var favoriteEvents: [Event]
    var business_type: String
    var vacation: Vacation?
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 30)
                .overlay(
                    Text("\(business_type.uppercased()) in \(selectedLocation)")
                        .foregroundColor(.white)
                        .padding()
                )
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
                .overlay(
                    Text("\(business_type.uppercased()) in \(selectedLocation)")
                        .foregroundColor(.white)
                        .padding()
                )
        }
        
        List(restaurants, id: \.id) { restaurant in
            NavigationLink(destination: BusinessDetailView(restaurant: restaurant, selectedLocation: $selectedLocation, favoriteRestaurants: $favoriteRestaurants, upcomingvacations: $upcomingvacations, selectedRestaurant: restaurant, favoriteEvents: $favoriteEvents)) {
                HStack {
                    AsyncImage(url: restaurant.image_url) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 50, height: 50)
                            .padding(.trailing)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 50, height: 50)
                            .padding(.trailing)
                    }
                    Text("\(restaurant.name)")
                }
            }
        }
        .onAppear {
            fetchRestaurants()
        }
    }

    func fetchRestaurants() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let yelpAPIKey = keys["YelpAPIKey"] as? String {
            
            guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=\(business_type)&location=\(selectedLocation)") else {
                return
            }

            var request = URLRequest(url: url)
            request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(YelpResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.restaurants = decodedResponse.businesses
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    }
}

struct BusinessDetailView: View {
    var restaurant: Restaurant
    @Binding var selectedLocation: String
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var upcomingvacations: [Vacation]
    var selectedRestaurant: Restaurant
    @Binding var favoriteEvents: [Event]
    var vacation: Vacation?
    @State private var showRecRestaurants = false
    @State private var isSheetReviewPresented = false
    @State private var isFavorite = false
    @State private var isSheetAddDatePresented = false
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack {
                HStack {
                    Text("\(restaurant.name)")
                        .font(.system(size: 25))
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Spacer()
                    
                    let imageUrl = URL(string: "\(restaurant.image_url)")!
                    URLImage(imageUrl) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 50, height: 50)
                    }
                    .padding()
                }
                
                MapView(coordinate: CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude))
                    .frame(height: 200)
                
                HStack {
                    Text("Address: \(restaurant.location.display_address.joined(separator: "\n"))")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("Phone: \(restaurant.display_phone)")
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("Cateogry:")
                    if let categories = restaurant.categories {
                        let categoryTitles = categories.map { $0.title }.joined(separator: ", ")
                        Text(categoryTitles)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("N/A")
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Button("Reviews ") {
                        isSheetReviewPresented.toggle()
                    }
                    .sheet(isPresented: $isSheetReviewPresented) {
                        ReviewSheetContentView(business_is_or_alias: restaurant.id)
                    }
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Button(action: { //add to favorites
                        if isFavorite {
                            if let index = favoriteRestaurants.firstIndex(where: { $0 == restaurant }) {
                                favoriteRestaurants.remove(at: index)
                            }
                        } else {
                            favoriteRestaurants.append(restaurant)
                        }
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.circle.fill" : "heart.circle")
                            .font(.system(size: 30))
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: { //sheet to add date to itinerary
                        isSheetAddDatePresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .padding()
                    }
                    .sheet(isPresented: $isSheetAddDatePresented) {
                        
                        AddRestaurantDate(selectedDate: Date(), selectedLocation: $selectedLocation, upcomingvacations: $upcomingvacations, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents,selectedRestaurant: selectedRestaurant)
                            //.presentationDetents([.fraction(0.2)])
                    }
                }
            }
            .padding()
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
            VStack {
                HStack{
                    MapView(coordinate: CLLocationCoordinate2D(latitude: restaurant.coordinates.latitude, longitude: restaurant.coordinates.longitude))
                        .frame(width: 250, height: 250)
                    VStack {
                        HStack {
                            let imageUrl = URL(string: "\(restaurant.image_url)")!
                            URLImage(imageUrl) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .frame(width: 50, height: 50)
                            }
                            .padding()
                            Text("\(restaurant.name)")
                                .font(.system(size: 25))
                                .multilineTextAlignment(.leading)
                                .padding()
                            
                            Spacer()
                            
                            
                        }
                        HStack {
                            VStack {
                                HStack {
                                    Text("Address: \(restaurant.location.display_address.joined(separator: "\n"))")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom)
                                
                                HStack {
                                    Text("Phone: \(restaurant.display_phone)")
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    Text("Cateogry:")
                                    if let categories = restaurant.categories {
                                        let categoryTitles = categories.map { $0.title }.joined(separator: ", ")
                                        Text(categoryTitles)
                                            .multilineTextAlignment(.leading)
                                    } else {
                                        Text("N/A")
                                    }
                                    Spacer()
                                }
                                .padding(.bottom)
                                
                                HStack {
                                    NavigationLink(destination: ReviewSheetContentView(business_is_or_alias: restaurant.id)) {
                                        Text("Reviews")
                                    }
                                    Spacer()
                                    HStack{
                                        Button(action: { //add to favorites
                                            if isFavorite {
                                                if let index = favoriteRestaurants.firstIndex(where: { $0 == restaurant }) {
                                                    favoriteRestaurants.remove(at: index)
                                                }
                                            } else {
                                                favoriteRestaurants.append(restaurant)
                                            }
                                            isFavorite.toggle()
                                        }) {
                                            Image(systemName: isFavorite ? "heart.circle.fill" : "heart.circle")
                                                .font(.system(size: 30))
                                                .padding()
                                        }
                                        
                                        NavigationLink(destination: AddRestaurantDate(selectedDate: Date(), selectedLocation: $selectedLocation, upcomingvacations: $upcomingvacations, favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents,selectedRestaurant: selectedRestaurant)) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 30))
                                                .padding()
                                        }
                                        
                                    }
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
                
            }
        }
    }
    
    func containsDestination(_ destination: String) -> Bool {
        return upcomingvacations.contains { $0.destination == destination }
    }
}

struct ReviewSheetContentView: View { //business reviews
    @State private var reviews = [YelpReview]()
    var business_is_or_alias: String
    
    var body: some View {
        List(reviews, id: \.id) { review in
            HStack {
                let imageUrl = URL(string: "\(review.user.image_url)")!
                URLImage(imageUrl) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .frame(width: 50, height: 50) // Adjust the frame size as needed
                }
                Text(review.user.name)
            }
            Text(review.text)
        }
        .onAppear {
            fetchReview()
        }
    }
    
    func fetchReview() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let yelpAPIKey = keys["YelpAPIKey"] as? String {
            
            guard let url = URL(string: "https://api.yelp.com/v3/businesses/\(business_is_or_alias)/reviews?limit=20&sort_by=yelp_sort") else {
                return
            }

            var request = URLRequest(url: url)
            request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(YelpReviewsResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.reviews = decodedResponse.reviews
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    }
}
 

struct AddRestaurantDate: View { //add date to business to add to itinerary
    @State var selectedDate: Date
    @Binding var selectedLocation: String
    @Binding var upcomingvacations: [Vacation]
    @Binding var favoriteRestaurants: [Restaurant]
    @Binding var favoriteEvents: [Event]
    var selectedRestaurant: Restaurant
    
    var body: some View {
        VStack {
            if containsDestination(selectedLocation) {
                let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                ExistingItinerary(vacation: upcomingvacations[index ?? 0], favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)
            }
            Form {
                Section(header: Text("Select Date and Time")) {
                    DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            Button("Add To Itinerary") {
                let addRestaurant = Restaurant(id: selectedRestaurant.id, alias: selectedRestaurant.alias, name: selectedRestaurant.name, image_url: selectedRestaurant.image_url, categories: selectedRestaurant.categories, rating: selectedRestaurant.rating, coordinates: selectedRestaurant.coordinates, price: selectedRestaurant.price, location: selectedRestaurant.location, phone: selectedRestaurant.phone, display_phone: selectedRestaurant.display_phone, date: selectedDate)
                
                if containsDestination(selectedLocation) {
                    let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                    upcomingvacations[index!].restaurantActivities.append(addRestaurant)
                }
                else {
                    var addVacation = Vacation(destination: selectedLocation)
                    addVacation.restaurantActivities.append(addRestaurant)

                    upcomingvacations.append(addVacation)
                }
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
    
    func containsDestination(_ destination: String) -> Bool {
        return upcomingvacations.contains { $0.destination == destination }
    }
}

struct ExistingBusinessDetails: View { //details of business already added to itinerary
    var selectedRestaurant: Restaurant
    @State private var isFavorite = false
    @State private var isSheetReviewPresented = false
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack {
                HStack {
                    Text("\(selectedRestaurant.name)")
                        .font(.system(size: 25))
                        .multilineTextAlignment(.leading)
                        .padding()
                    
                    Spacer()
                    
                    let imageUrl = URL(string: "\(selectedRestaurant.image_url)")!
                    URLImage(imageUrl) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 50, height: 50)
                    }
                    .padding()
                }
                
                MapView(coordinate: CLLocationCoordinate2D(latitude: selectedRestaurant.coordinates.latitude, longitude: selectedRestaurant.coordinates.longitude))
                    .frame(height: 200)
                
                HStack {
                    Text("Address: \(selectedRestaurant.location.display_address.joined(separator: "\n"))")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("Phone: \(selectedRestaurant.display_phone)")
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Text("Cateogry:")
                    if let categories = selectedRestaurant.categories {
                        let categoryTitles = categories.map { $0.title }.joined(separator: ", ")
                        Text(categoryTitles)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("N/A")
                    }
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    Button("Reviews ") {
                        isSheetReviewPresented.toggle()
                    }
                    .sheet(isPresented: $isSheetReviewPresented) {
                        ReviewSheetContentView(business_is_or_alias: selectedRestaurant.id)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
            VStack {
                HStack{
                    MapView(coordinate: CLLocationCoordinate2D(latitude: selectedRestaurant.coordinates.latitude, longitude: selectedRestaurant.coordinates.longitude))
                        .frame(width: 250, height: 250)
                    VStack {
                        HStack {
                            let imageUrl = URL(string: "\(selectedRestaurant.image_url)")!
                            URLImage(imageUrl) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .frame(width: 50, height: 50)
                            }
                            .padding()
                            Text("\(selectedRestaurant.name)")
                                .font(.system(size: 25))
                                .multilineTextAlignment(.leading)
                                .padding()
                            
                            Spacer()
                            
                            
                        }
                        HStack {
                            VStack {
                                HStack {
                                    Text("Address: \(selectedRestaurant.location.display_address.joined(separator: "\n"))")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom)
                                
                                HStack {
                                    Text("Phone: \(selectedRestaurant.display_phone)")
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    Text("Cateogry:")
                                    if let categories = selectedRestaurant.categories {
                                        let categoryTitles = categories.map { $0.title }.joined(separator: ", ")
                                        Text(categoryTitles)
                                            .multilineTextAlignment(.leading)
                                    } else {
                                        Text("N/A")
                                    }
                                    Spacer()
                                }
                                .padding(.bottom)
                                
                                HStack {
                                    NavigationLink(destination: ReviewSheetContentView(business_is_or_alias: selectedRestaurant.id)) {
                                        Text("Reviews")
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}


