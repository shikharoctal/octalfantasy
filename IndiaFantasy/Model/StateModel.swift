//
//  StateModel.swift
//  India’s fantasy
//
//  Created by admin on 24/04/23.
//

import Foundation

struct State : Codable {
 
    var id : String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}
