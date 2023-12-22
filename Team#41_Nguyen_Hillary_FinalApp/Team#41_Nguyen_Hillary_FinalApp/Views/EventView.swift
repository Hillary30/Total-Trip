//
//  EventView.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import SwiftUI
import MapKit
import URLImage


//Events
struct EventList: View {
    @State var selectedLocation: String
    @State private var events = [Event]()
    @State private var selectedEvent: Event? = nil
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    var category: String
    @Binding var favoriteRestaurants: [Restaurant]
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 30)
                .overlay(
                    Text("\(category.uppercased()) in \(selectedLocation)")
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
                    Text("\(category.uppercased()) in \(selectedLocation)")
                        .foregroundColor(.white)
                        .padding()
                )
        }
        
        VStack {
            
            List(events) { event in
                VStack(alignment: .leading) {
                    NavigationLink(
                        destination: EventDetailsView(
                            event: event,
                            selectedLocation: $selectedLocation,
                            favoriteEvents: $favoriteEvents,
                            upcomingvacations: $upcomingvacations,
                            selectedEvent: event, favoriteRestaurants: $favoriteRestaurants
                    ))
                    {
                        HStack {
                            if (event.image_url != nil || event.image_url != "") {
                                AsyncImage(url: URL(string: event.image_url ?? "")) { image in
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
                            else {
                                Circle()
                                    .fill(Color.gray)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 10)
                                    .frame(width: 50, height: 50)
                                    .padding(.trailing)
                            }
                            Text("\(event.name ?? "")")
                        }
                    }
                }
            }
            .onAppear {
                fetchEvents()
            }
        }
        //.navigationBarTitle(Text("\(category.uppercased()) in \(selectedLocation)").foregroundColor(.white))
    }
    
    func fetchEvents() {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let yelpAPIKey = keys["YelpAPIKey"] as? String {
            
            guard let url = URL(string: "https://api.yelp.com/v3/events?locale=en_US&limit=20&sort_by=asc&sort_on=popularity&categories=\(category)&location=\(selectedLocation)") else {
                return
            }

            var request = URLRequest(url: url)
            request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        let decodedResponse = try JSONDecoder().decode(YelpResponseEvent.self, from: data)
                        DispatchQueue.main.async {
                            self.events = decodedResponse.events
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    }
    
    private func eventLocationString(_ event: Event) -> String {
        let formattedAddress = event.location?.address1
        return "\(formattedAddress ?? ""), \(event.location?.city ?? "" ), \(event.location?.state ?? "")"
    }
}

struct EventDetailsView: View {
    var event: Event
    @Binding var selectedLocation: String
    @Binding var favoriteEvents: [Event]
    @Binding var upcomingvacations: [Vacation]
    var selectedEvent: Event
    @Binding var favoriteRestaurants: [Restaurant]
    @State private var showRecEvents = false
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
                    Text(event.name ?? "")
                        .font(.system(size: 25))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if (event.image_url != nil || event.image_url != "") {
                        AsyncImage(url: URL(string: event.image_url ?? "")) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                                .frame(width: 50, height: 50)
                        } placeholder: {
                        }
                    }
                }
                
                if (event.latitude != nil) {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0))
                        .frame(height: 200)
                }
                HStack {
                    Text("Address: \n \(event.location?.displayAddress?.joined(separator: "\n") ?? "")")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    if event.is_free != nil {
                        if event.is_free == true {
                            Text("Free Event")
                            Spacer()
                        }
                        else {
                            Text("Event may require money")
                            Spacer()
                        }
                    }
                }
                
                //Text("Website: \(selectedEvent.event_site_url ?? "")")
                HStack {
                    Text("Cateogry: \(event.category ?? "N/A")")
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    if event.attending_count != nil {
                        Text("Attending: \(event.attending_count ?? 0)")
                    }
                    else {
                        Text("Attending: N/A")
                    }
                    Spacer()
                    if event.interested_count != nil {
                        Text("Interested: \(event.interested_count ?? 0)")
                    }
                    else {
                        Text("Interest: N/A")
                    }
                }
                .padding(.bottom)
                
                HStack {
                    if event.time_start != nil {
                        if let date = convertToDate(date: event.time_start ?? "") {
                            Text("Starts: \(date)")
                        } else {
                            Text("Starts: \(event.time_start ?? "N/A")")
                        }
                    }
                    else {
                        Text("Starts: N/A")
                    }
                    Spacer()
                    if event.time_end != nil {
                        if let date = convertToDate(date: event.time_end ?? "") {
                            Text("Ends: \(date)")
                        } else {
                            Text("Ends: \(event.time_end ?? "N/A")")
                        }
                    }
                    else {
                        Text("Ends: N/A")
                    }
                }
                
                HStack {
                    Button(action: { //add to favorites
                        if isFavorite {
                            if let index = favoriteEvents.firstIndex(where: { $0 == event }) {
                                favoriteEvents.remove(at: index)
                            }
                        } else {
                            favoriteEvents.append(event)
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
                        AddEventDate(selectedDate: Date(), selectedLocation: $selectedLocation, upcomingvacations: $upcomingvacations,selectedEvent: selectedEvent, favoriteEvents: $favoriteEvents,favoriteRestaurants: $favoriteRestaurants)
                            //.presentationDetents([.fraction(0.2)])
                    }
                }
            }
            .padding()
            Spacer()
        }
        
        
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
            VStack {
                HStack{
                    if (event.latitude != nil) {
                        MapView(coordinate: CLLocationCoordinate2D(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0))
                            .frame(width: 250, height: 250)
                            .padding(.trailing)
                    }
                    VStack {
                        HStack {
                            if (event.image_url != nil || event.image_url != "") {
                                AsyncImage(url: URL(string: event.image_url ?? "")) { image in
                                    image
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 10)
                                        .frame(width: 50, height: 50)
                                } placeholder: {
                                }
                            }
                            Text(event.name ?? "")
                                .font(.system(size: 25))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        Spacer().frame(height: 30)
                        HStack {
                            VStack {
                                HStack {
                                    Text("Address: \(event.location?.displayAddress?.joined(separator: "\n") ?? "")")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    Text("Cateogry: \(event.category ?? "N/A")")
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    if event.attending_count != nil {
                                        Text("Attending: \(event.attending_count ?? 0)")
                                    }
                                    else {
                                        Text("Attending: N/A")
                                    }
                                    if event.interested_count != nil {
                                        Text("Interested: \(event.interested_count ?? 0)")
                                    }
                                    else {
                                        Text("Interest: N/A")
                                    }
                                    Spacer()
                                }
                                .padding(.bottom)
                            }
                            Spacer() //adjust spacer size
                            VStack {
                                if event.time_start != nil {
                                    if let date = convertToDate(date: event.time_start ?? "") {
                                        Text("Starts: \(date)")
                                    } else {
                                        Text("Starts: \(event.time_start ?? "N/A")")
                                    }
                                }
                                else {
                                    Text("Starts: N/A")
                                }
                                Spacer().frame(height: 20)
                                if event.time_end != nil {
                                    if let date = convertToDate(date: event.time_end ?? "") {
                                        Text("Ends: \(date)")
                                    } else {
                                        Text("Ends: \(event.time_end ?? "N/A")")
                                    }
                                }
                                else {
                                    Text("Ends: N/A")
                                }
                            }
                            .frame(width: 200)
                        }//HStack
                        Spacer()
                    } //VStack
                    Spacer()
                    
                }
                HStack {
                    Button(action: { //add to favorites
                        if isFavorite {
                            if let index = favoriteEvents.firstIndex(where: { $0 == event }) {
                                favoriteEvents.remove(at: index)
                            }
                        } else {
                            favoriteEvents.append(event)
                        }
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.circle.fill" : "heart.circle")
                            .font(.system(size: 30))
                            .padding()
                    }
                    Button(action: { //sheet to add date to itinerary
                        isSheetAddDatePresented.toggle()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30))
                            .padding()
                    }
                    .sheet(isPresented: $isSheetAddDatePresented) {
                        AddEventDate(selectedDate: Date(), selectedLocation: $selectedLocation, upcomingvacations: $upcomingvacations,selectedEvent: selectedEvent, favoriteEvents: $favoriteEvents,favoriteRestaurants: $favoriteRestaurants)
                            //.presentationDetents([.fraction(0.2)])
                    }
                }
            }
        }
    }
    
    func containsDestination(_ destination: String) -> Bool {
        return upcomingvacations.contains { $0.destination == destination }
    }
    
    func convertToDate(date: String) -> Date? {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure the locale is set to "en_US_POSIX" for a stable date conversion
            
            return formatter.date(from: date)
        }
}


struct AddEventDate: View { //put date on activity to add to itinerary
    @State var selectedDate: Date
    @Binding var selectedLocation: String
    @Binding var upcomingvacations: [Vacation]
    var selectedEvent: Event
    @Binding var favoriteEvents: [Event]
    @Binding var favoriteRestaurants: [Restaurant]
    
    var body: some View {
        VStack {
            if containsDestination(selectedLocation) {
                let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                ExistingItinerary(vacation: upcomingvacations[index ?? 0], favoriteRestaurants: $favoriteRestaurants, favoriteEvents: $favoriteEvents, upcomingvacations: $upcomingvacations)
            }
            Spacer()
            Form {
                Section(header: Text("Select Date and Time")) {
                    DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            Button("Add To Itinerary") {
                let addEvent = Event(id: selectedEvent.id, name: selectedEvent.name, description: selectedEvent.description, business_id: selectedEvent.business_id, category: selectedEvent.category, cost: selectedEvent.cost, cost_max: selectedEvent.cost_max, event_site_url: selectedEvent.event_site_url, image_url: selectedEvent.image_url, tickets_url: selectedEvent.tickets_url, attending_count: selectedEvent.attending_count, interested_count: selectedEvent.interested_count, is_canceled: selectedEvent.is_canceled, is_free: selectedEvent.is_free, is_official: selectedEvent.is_official, location: selectedEvent.location, latitude: selectedEvent.latitude, longitude: selectedEvent.longitude, time_start: selectedEvent.time_start, time_end: selectedEvent.time_end, date: selectedDate)
                
                if containsDestination(selectedLocation) {
                    let index = upcomingvacations.firstIndex(where: { $0.destination == "\(selectedLocation)" })
                    upcomingvacations[index!].eventActivities.append(addEvent)
                }
                else {
                    var addVacation = Vacation(destination: selectedLocation)
                    addVacation.eventActivities.append(addEvent)

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


struct ExistingEventDetails: View { //details of event already added
    var selectedEvent: Event
    @State private var isFavorite = false
    @Environment(\.verticalSizeClass) var HeightSizeClass: UserInterfaceSizeClass?
    
    var body: some View {
        if HeightSizeClass == .regular {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 10)
            VStack {
                HStack {
                    Text(selectedEvent.name ?? "")
                        .font(.system(size: 25))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    if (selectedEvent.image_url != nil || selectedEvent.image_url != "") {
                        AsyncImage(url: URL(string: selectedEvent.image_url ?? "")) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                                .frame(width: 50, height: 50)
                        } placeholder: {
                        }
                    }
                }
                
                if (selectedEvent.latitude != nil) {
                    MapView(coordinate: CLLocationCoordinate2D(latitude: selectedEvent.latitude ?? 0, longitude: selectedEvent.longitude ?? 0))
                        .frame(height: 200)
                }
                HStack {
                    Text("Address: \n \(selectedEvent.location?.displayAddress?.joined(separator: "\n") ?? "")")
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    if selectedEvent.is_free != nil {
                        if selectedEvent.is_free == true {
                            Text("Free Event")
                            Spacer()
                        }
                        else {
                            Text("Event may require money")
                            Spacer()
                        }
                    }
                }
                
                //Text("Website: \(selectedEvent.event_site_url ?? "")")
                HStack {
                    Text("Cateogry: \(selectedEvent.category ?? "N/A")")
                    Spacer()
                }
                .padding(.bottom)
                
                HStack {
                    if selectedEvent.attending_count != nil {
                        Text("Attending: \(selectedEvent.attending_count ?? 0)")
                    }
                    else {
                        Text("Attending: N/A")
                    }
                    Spacer()
                    if selectedEvent.interested_count != nil {
                        Text("Interested: \(selectedEvent.interested_count ?? 0)")
                    }
                    else {
                        Text("Interest: N/A")
                    }
                }
                .padding(.bottom)
                
                HStack {
                    if selectedEvent.time_start != nil {
                        if let date = convertToDate(date: selectedEvent.time_start ?? "") {
                            Text("Starts: \(date)")
                        } else {
                            Text("Starts: \(selectedEvent.time_start ?? "N/A")")
                        }
                    }
                    else {
                        Text("Starts: N/A")
                    }
                    Spacer()
                    if selectedEvent.time_end != nil {
                        if let date = convertToDate(date: selectedEvent.time_end ?? "") {
                            Text("Ends: \(date)")
                        } else {
                            Text("Ends: \(selectedEvent.time_end ?? "N/A")")
                        }
                    }
                    else {
                        Text("Ends: N/A")
                    }
                }
            }
            .padding()
            Spacer()
        }
        
        
        if HeightSizeClass == .compact {
            Rectangle()
                .fill(dark_blue)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: 15)
            VStack {
                HStack{
                    if (selectedEvent.latitude != nil) {
                        MapView(coordinate: CLLocationCoordinate2D(latitude: selectedEvent.latitude ?? 0, longitude: selectedEvent.longitude ?? 0))
                            .frame(width: 250, height: 250)
                            .padding(.trailing)
                    }
                    VStack {
                        HStack {
                            if (selectedEvent.image_url != nil || selectedEvent.image_url != "") {
                                AsyncImage(url: URL(string: selectedEvent.image_url ?? "")) { image in
                                    image
                                        .resizable()
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                        .shadow(radius: 10)
                                        .frame(width: 50, height: 50)
                                } placeholder: {
                                }
                            }
                            Text(selectedEvent.name ?? "")
                                .font(.system(size: 25))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            
                        }
                        Spacer().frame(height: 30)
                        HStack {
                            VStack {
                                HStack {
                                    Text("Address: \(selectedEvent.location?.displayAddress?.joined(separator: "\n") ?? "")")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    Text("Cateogry: \(selectedEvent.category ?? "N/A")")
                                    Spacer()
                                }
                                .padding(.bottom)
                                HStack {
                                    if selectedEvent.attending_count != nil {
                                        Text("Attending: \(selectedEvent.attending_count ?? 0)")
                                    }
                                    else {
                                        Text("Attending: N/A")
                                    }
                                    if selectedEvent.interested_count != nil {
                                        Text("Interested: \(selectedEvent.interested_count ?? 0)")
                                    }
                                    else {
                                        Text("Interest: N/A")
                                    }
                                    Spacer()
                                }
                                .padding(.bottom)
                            }
                            Spacer() //adjust spacer size
                            VStack {
                                if selectedEvent.time_start != nil {
                                    if let date = convertToDate(date: selectedEvent.time_start ?? "") {
                                        Text("Starts: \(date)")
                                    } else {
                                        Text("Starts: \(selectedEvent.time_start ?? "N/A")")
                                    }
                                }
                                else {
                                    Text("Starts: N/A")
                                }
                                Spacer().frame(height: 20)
                                if selectedEvent.time_end != nil {
                                    if let date = convertToDate(date: selectedEvent.time_end ?? "") {
                                        Text("Ends: \(date)")
                                    } else {
                                        Text("Ends: \(selectedEvent.time_end ?? "N/A")")
                                    }
                                }
                                else {
                                    Text("Ends: N/A")
                                }
                            }
                            .frame(width: 200)
                        }//HStack
                        Spacer()
                    } //VStack
                    Spacer()
                }
            }
        }
    }
        
    func convertToDate(date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Ensure the locale is set to "en_US_POSIX" for a stable date conversion
        
        return formatter.date(from: date)
    }
}



