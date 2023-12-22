//
//  HotelDataModel.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import Foundation

struct YelpHotelResponse: Decodable {
    var businesses: [Business]
    var total: Int?
    var region: Center
}

struct Center: Decodable {
    var center: Coordinate
}

struct Business: Decodable, Identifiable {
    var id: String
    var alias: String
    var name: String
    var image_url: URL?
    var is_closed: Bool?
    var url: URL?
    var review_count: Int?
    var categories: [YelpCategory]
    var rating: Float?
    var coordinates: Coordinate
    var transactions: [String]?
    var price: String?
    var location: Location
    var phone: String
    var display_phone: String
    var distance: Float?
    var hours: [Hours]?
}

struct YelpCategory: Decodable {
    var alias: String
    var title: String
}

struct Coordinate: Decodable {
    var latitude: Double
    var longitude: Double
}

struct Location: Decodable {
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var zip_code: String?
    var country: String?
    var state: String?
    var display_address: [String]
    var cross_street: String?
}

struct Hours: Decodable {
    var hour_type: String
    var open: [HourList]
    var is_open_now: Bool
}

struct HourList: Decodable {
    var day: Int
    var start: String
    var end: String
    var is_overnight: Bool
}
