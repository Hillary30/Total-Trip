//
//  DataModel.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import Foundation

struct Vacation: Identifiable {
    let id = UUID()
    var destination: String
    var restaurantActivities: [Restaurant] = []
    var eventActivities: [Event] = []
    var hotel: Business?
}

// Sample data
var UpcomingVacations: [Vacation] = [Vacation(destination: "Spain"), Vacation(destination: "London"), Vacation(destination: "Paris"), Vacation(destination: "Italy"), Vacation(destination: "India")]
var PastVacations: [Vacation] = [Vacation(destination: "Australia"), Vacation(destination: "Dubai"), Vacation(destination: "Croatia"), Vacation(destination: "Canada"), Vacation(destination: "Indonesia")]

struct Restaurant: Identifiable, Decodable, Hashable, Equatable {
    var id: String
    var alias: String
    var name: String
    var image_url: URL
    var categories: [Category]?
    var rating: Float?
    var coordinates: Coordinates
    var price: String?
    var location: Location
    var phone: String
    var display_phone: String
    
    struct Category: Decodable {
        var alias: String
        var title: String
    }
    
    struct Coordinates: Decodable {
        var latitude: Double
        var longitude: Double
    }
    
    struct Location: Decodable {
        var city: String?
        var country: String?
        var address1: String?
        var display_address: [String]
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var date: Date?
    
    mutating func modifyingValue(newDate: Date) {
        self.date = newDate
    }
}

struct YelpResponse: Decodable {
    var businesses: [Restaurant]
}

//Business Reviews
struct YelpReview: Decodable, Identifiable {
    let id: String
    let url: String
    let text: String
    let rating: Int
    let time_created: String // You may want to convert this to a Date type
    let user: YelpUser
}

struct YelpUser: Codable {
    let id: String
    let profile_url: String?
    let image_url: String
    let name: String
}

struct YelpReviewsResponse: Decodable {
    let total: Int
    let reviews: [YelpReview]
    let possible_languages: [String]
}

//Events
struct Event: Identifiable, Codable, Hashable, Equatable {
    var id: String
    var name: String?
    var description: String?
    var business_id: String?
    var category: String?
    var cost: Double?
    var cost_max: Double?
    var event_site_url: String?
    var image_url: String?
    var tickets_url: String?
    var attending_count: Int?
    var interested_count: Int?
    var is_canceled: Bool?
    var is_free: Bool?
    var is_official: Bool?
    var location: EventLocation?
    var latitude: Double?
    var longitude: Double?
    var time_start: String?
    var time_end: String?
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var date: Date?
    
    mutating func modifyingValue(newDate: Date) {
        self.date = newDate
    }
}

struct EventLocation: Codable {
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    var displayAddress: [String]?
    var crossStreets: String?
}


struct YelpResponseEvent: Codable {
    var events: [Event]
    var total: Int
}
