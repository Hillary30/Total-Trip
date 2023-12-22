//
//  HotelView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import Foundation
import CoreLocation
import URLImage

struct HotelView: View { //list of available hotels
    @State private var hotels: [Business] = []
    @Binding var upcomingvacations: [Vacation]
    var selectedLocation: String
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?


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
        List(hotels) { hotel in
            NavigationLink(destination: HotelDetail(hotel: hotel, selectedLocation: selectedLocation, upcomingvacations: $upcomingvacations)) {
                HotelRow(hotel: hotel)
            }
        }
        .navigationBarTitle("Hotels in \(selectedLocation)")
        .onAppear {
            fetchData()
        }
    }

    func fetchData() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let yelpAPIKey = keys["YelpAPIKey"] as? String {
            
            guard let url = URL(string: "https://api.yelp.com/v3/businesses/search?location=\(selectedLocation)&term=hotels&sort_by=best_match&limit=20") else {
                return
            }

            var request = URLRequest(url: url)
            request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(YelpHotelResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.hotels = decodedResponse.businesses
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    }
}

struct HotelRow: View { //individual hotel in list
    var hotel: Business

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: hotel.image_url) { image in
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
                VStack {
                    HStack {
                        Text(hotel.name)
                            .font(.headline)
                        Spacer()
                    }
                    HStack {
                        Text("Rating: \(ratingFormatter(value: hotel.rating ?? 0)) / 5")
                        Spacer()
                    }
                }
            }
        }
    }
    
    func ratingFormatter(value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        if let formattedString = formatter.string(for: value) {
            return formattedString
        }
        else {
            return String(value)
        }
    }
}

struct HotelDetail: View {
    var hotel: Business
    var selectedLocation: String
    @Binding var upcomingvacations: [Vacation]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    @State private var isSheetReviewPresented = false

    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack {
                HStack {
                    Text(hotel.name)
                        .font(.title)
                    Spacer()
                    AsyncImage(url: hotel.image_url) { image in
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
                }
                
                MapView(coordinate: CLLocationCoordinate2D(latitude: hotel.coordinates.latitude, longitude: hotel.coordinates.longitude ))
                    .frame(height: 200)
                HStack {
                    Text("Address: \(hotel.location.address1 ?? "")")
                        .font(.subheadline)
                        .padding([.bottom, .top])
                    Spacer()
                    Text(hotel.price ?? "")
                        .padding()
                }
                HStack {
                    Text("Rating: \(ratingFormatter(value: hotel.rating ?? 0)) / 5")
                        .padding([.bottom, .top])
                    Spacer()
                }
                
                HStack {
                    Text("Phone: \(hotel.display_phone)")
                        .padding([.bottom, .top])
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    Button("Reviews ") {
                        isSheetReviewPresented.toggle()
                    }
                    .sheet(isPresented: $isSheetReviewPresented) {
                        ReviewSheetContentView(business_is_or_alias: hotel.id)
                    }
                    
                    Spacer()
                    Button(action: {
                        if containsDestination(selectedLocation) {
                            let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                            upcomingvacations[index!].hotel = hotel
                        }
                        else {
                            var addVacation = Vacation(destination: selectedLocation)
                            addVacation.hotel = hotel

                            upcomingvacations.append(addVacation)
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .padding()
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
                HStack {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: hotel.coordinates.latitude, longitude: hotel.coordinates.longitude ))
                        .frame(width: 250, height: 250)
                        .padding(.trailing)
                    VStack {
                        HStack {
                            AsyncImage(url: hotel.image_url) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .frame(width: 50, height: 50)
                                    .padding()
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .frame(width: 50, height: 50)
                                    .padding()
                            }
                            
                            Text(hotel.name)
                                .font(.title)
                            Spacer()
                        }
                        HStack {
                            HStack {
                                Text("Address: \(hotel.location.address1 ?? "")")
                                    .font(.subheadline)
                                    .padding(.bottom)
                                Spacer()
                                Text(hotel.price ?? "")
                                    .padding(.bottom)
                            }
                        }
                        HStack {
                            Text("Rating: \(ratingFormatter(value: hotel.rating ?? 0)) / 5")
                                .padding(.bottom)
                            Spacer()
                        }
                        
                        HStack {
                            Text("Phone: \(hotel.display_phone)")
                                .padding(.bottom)
                            Spacer()
                        }
                        HStack {
                            NavigationLink(destination: ReviewSheetContentView(business_is_or_alias: hotel.id)) {
                                Text("Reviews")
                                    .padding()
                            }
                            Spacer()
                            Button(action: { //sheet to add date to itinerary
                                if containsDestination(selectedLocation) {
                                    let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                                    upcomingvacations[index!].hotel = hotel
                                }
                                else {
                                    var addVacation = Vacation(destination: selectedLocation)
                                    addVacation.hotel = hotel

                                    upcomingvacations.append(addVacation)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 30))
                                    .padding()
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
    
    func containsDestination(_ destination: String) -> Bool {
        return upcomingvacations.contains { $0.destination == destination }
    }
    
    func ratingFormatter(value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        if let formattedString = formatter.string(for: value) {
            return formattedString
        }
        else {
            return String(value)
        }
    }
}

//hotel details already added
struct ExistingHotel: View {
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    @Binding var upcomingvacations: [Vacation]
    var vacation: Vacation
    var body: some View {
        
        let index = upcomingvacations.firstIndex(where: { $0.destination == "\(vacation.destination)" })
        
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            if index == nil || vacation.hotel == nil {
                VStack {
                    Text("Hotel for \(vacation.destination)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Add a Hotel!")
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: HotelView(upcomingvacations: $upcomingvacations, selectedLocation: vacation.destination)) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 30))
                                .padding()
                        }
                    }
                }
            }
            if vacation.hotel != nil || index != nil {
                if upcomingvacations[index ?? 0].hotel != nil {
                    VStack {
                        HStack {
                            Text(upcomingvacations[index ?? 0].hotel?.name ?? "")
                                .font(.title)
                            Spacer()
                            AsyncImage(url: upcomingvacations[index ?? 0].hotel?.image_url) { image in
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
                        }
                        
                        if upcomingvacations[index ?? 0].hotel?.coordinates.latitude != nil {
                            MapView(coordinate: CLLocationCoordinate2D(latitude: (upcomingvacations[index ?? 0].hotel?.coordinates.latitude)!, longitude: (upcomingvacations[index ?? 0].hotel?.coordinates.longitude)! ))
                                .frame(height: 200)
                        }
                        HStack {
                            Text("Address: \(upcomingvacations[index ?? 0].hotel?.location.address1 ?? "")")
                                .font(.subheadline)
                                .padding([.bottom, .top])
                            Spacer()
                            Text(upcomingvacations[index ?? 0].hotel?.price ?? "")
                                .padding()
                        }
                        HStack {
                            Text("Rating: \(ratingFormatter(value: upcomingvacations[index ?? 0].hotel?.rating ?? 0)) / 5")
                                .padding([.bottom, .top])
                            Spacer()
                        }
                        
                        HStack {
                            Text("Phone: \(upcomingvacations[index ?? 0].hotel?.display_phone ?? "N/A")")
                                .padding([.bottom, .top])
                            Spacer()
                        }
                        
                        Spacer()
                        
                    }
                    .padding()
                }
            }
        }
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            if index == nil {
                VStack {
                    Text("Hotel for \(vacation.destination)")
                        .font(.system(size: 25))
                        .fontWeight(.bold)
                        .padding()
                    
                    Text("Add a Hotel!")
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        NavigationLink(destination: HotelView(upcomingvacations: $upcomingvacations, selectedLocation: vacation.destination)) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 30))
                                .padding()
                        }
                    }
                }
            }
            if vacation.hotel != nil || index != nil {
                if upcomingvacations[index ?? 0].hotel != nil {
                    VStack {
                        HStack {
                            if upcomingvacations[index ?? 0].hotel?.coordinates.latitude != nil {
                                MapView(coordinate: CLLocationCoordinate2D(latitude: (upcomingvacations[index ?? 0].hotel?.coordinates.latitude)!, longitude: (upcomingvacations[index ?? 0].hotel?.coordinates.longitude)! ))
                                    .frame(width: 250, height: 250)
                            }
                            VStack {
                                HStack {
                                    AsyncImage(url: upcomingvacations[index ?? 0].hotel?.image_url) { image in
                                        image
                                            .resizable()
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                            .shadow(radius: 10)
                                            .frame(width: 50, height: 50)
                                            .padding()
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                            .shadow(radius: 10)
                                            .frame(width: 50, height: 50)
                                            .padding()
                                    }
                                    
                                    Text(upcomingvacations[index ?? 0].hotel?.name ?? "")
                                        .font(.title)
                                    Spacer()
                                }
                                HStack {
                                    Text("Address: \(upcomingvacations[index ?? 0].hotel?.location.address1 ?? "")")
                                        .font(.subheadline)
                                        .padding(.bottom)
                                    Spacer()
                                    Text(upcomingvacations[index ?? 0].hotel?.price ?? "")
                                        .padding(.bottom)
                                }
                                HStack {
                                    Text("Rating: \(ratingFormatter(value: upcomingvacations[index ?? 0].hotel?.rating ?? 0)) / 5")
                                        .padding(.bottom)
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Phone: \(upcomingvacations[index ?? 0].hotel?.display_phone ?? "N/A")")
                                        .padding(.bottom)
                                    Spacer()
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    func ratingFormatter(value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        if let formattedString = formatter.string(for: value) {
            return formattedString
        }
        else {
            return String(value)
        }
    }
}


