//
//  Location.swift
//
//  Created by Bedirhan SAMSA on 14.02.2025.
//


import Foundation

struct Location: Codable {
    let country: Country
    let city: City
    let district: District
    
    struct Country: Codable, Equatable, Identifiable {
        let id: String
        let name: String
        let code: String
    }
    
    struct City: Identifiable, Codable {
        let id: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "SehirID"
            case name = "SehirAdi"
        }
    }
    
    struct District: Codable, Equatable, Identifiable {
        let id: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case id = "IlceID"
            case name = "IlceAdi"
        }
    }
}
