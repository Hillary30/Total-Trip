//
//  SearchObjectController.swift
//  Team#41_Nguyen_Hillary_FinalApp
//
//  Created by user237047 on 11/30/23.
//

import Foundation
import SwiftUI
import URLImage

class SearchObjectController : ObservableObject {
    static let shared = SearchObjectController()
    private init() {}
    
    var token = "YOUR_UNSPLASH_TOKEN"
    @Published var results = [Result]()
    
    func search(for query: String) {
        let urlString = "https://api.unsplash.com/search/photos?query=\(query)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(Results.self, from: data)
                self.results.append(contentsOf: res.results)
                print("query: \(query)")
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func imageURL(for country: String) -> String? {
            return results.first { $0.description?.contains(country) ?? false }?.urls.small
        }
}


