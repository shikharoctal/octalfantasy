//
//  SeriesListModel.swift
//  India’s fantasy
//
//  Created by admin on 01/06/23.
//

import Foundation

// MARK: - Match Series
struct MatchSeries: Decodable {
    let id: String?
    let idAPI: Int?
    let name, resultID, seriesStatus: String?
    let isFavourite: Bool?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case idAPI = "id_api"
        case name
        case resultID = "id"
        case seriesStatus = "series_status"
        case isFavourite
    }
}
