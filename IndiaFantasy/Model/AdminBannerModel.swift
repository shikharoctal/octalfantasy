//
//  AdminBannerModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 24/06/24.
//

import Foundation

// MARK: - Admin Banners Result
struct AdminBannersResult: Codable {
    let type: String?
    let mediaURL: String?

    enum CodingKeys: String, CodingKey {
        case type
        case mediaURL = "media_url"
    }
}
