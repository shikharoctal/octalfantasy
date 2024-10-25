//
//  BannerModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 23/05/24.
//

import Foundation

struct Banner : Codable {
    
    let  sequence: Int?
    let  id, link, title, banner_type, offer_id, series_id, match_id, start_date, end_date, media_type, status, image, created_at, updated_at, idnumber: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sequence = "sequence"
        case link = "link"
        case title = "title"
        case banner_type = "banner_type"
        case offer_id = "offer_id"
        case series_id = "series_id"
        case match_id = "match_id"
        case start_date = "start_date"
        case end_date = "end_date"
        case media_type = "media_type"
        case status = "status"
        case image = "image"
        case created_at = "created_at"
        case updated_at = "updated_at"
        case idnumber = "id"

    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        sequence = values.decodeSafely(Int.self, forKey: .sequence)
        link = values.decodeSafely(String.self, forKey: .link)
        title = values.decodeSafely(String.self, forKey: .title)
        banner_type = values.decodeSafely(String.self, forKey: .banner_type)
        offer_id = values.decodeSafely(String.self, forKey: .offer_id)
        series_id = values.decodeSafely(String.self, forKey: .series_id)
        match_id = values.decodeSafely(String.self, forKey: .match_id)
        start_date = values.decodeSafely(String.self, forKey: .start_date)
        end_date = values.decodeSafely(String.self, forKey: .end_date)
        media_type = values.decodeSafely(String.self, forKey: .series_id)
        status = values.decodeSafely(String.self, forKey: .status)
        image = values.decodeSafely(String.self, forKey: .image)
        created_at = values.decodeSafely(String.self, forKey: .created_at)
        updated_at = values.decodeSafely(String.self, forKey: .updated_at)
        idnumber = values.decodeSafely(String.self, forKey: .idnumber)

    }
}
