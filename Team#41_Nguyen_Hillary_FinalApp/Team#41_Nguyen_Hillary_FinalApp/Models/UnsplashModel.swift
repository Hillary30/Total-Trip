//
//  UnsplashModel.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import Foundation
import SwiftUI

struct Results: Codable {
    var total: Int
    var results: [Result]
}

struct Result: Codable {
    var id: String
    var description: String?
    var urls: URLs
}

struct URLs: Codable {
    var small: String
}

