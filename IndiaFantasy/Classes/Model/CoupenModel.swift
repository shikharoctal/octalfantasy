//
//  CoupenModel.swift
//  KnockOut11
//
//  Created by Subhash Sharma on 16/09/22.
//

import Foundation
// MARK: - CoupenModal
struct CoupenModal: Codable {
    var success: Bool?
    var msg, errors: String?
    var results: [CoupenResult]?
}

// MARK: - Result
struct CoupenResult: Codable {
    var flatDiscount, minDiscount, maxDiscount, cashbackPercent, expireInDays: Int?
    var usageLimit, limitPerUser: Int?
    var id, couponCode, type, startDate, description: String?
    var endDate, status, createdAt, updatedAt: String?
    var v: Int?
    var resultID: String?

    enum CodingKeys: String, CodingKey {
        case flatDiscount = "flat_discount"
        case minDiscount = "min_discount"
        case maxDiscount = "max_discount"
        case cashbackPercent = "cashback_percent"
        case usageLimit = "usage_limit"
        case limitPerUser = "limit_per_user"
        case id = "_id"
        case couponCode = "coupon_code"
        case type
        case startDate = "start_date"
        case description
        case endDate = "end_date"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case resultID = "id"
        case expireInDays = "expire_in_days"
    }
}

struct PromoCode : Codable {
    
    let discount_value: Float?
    let id, status, apply_type, code : String?
    let description_ar, description_en : String?
    let discount_type, promo_for : String?
    let title_ar, title_en : String?
    let updatedAt, from, to, image_url : String?
           
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case discount_value = "discount_value"
        case status = "status"
        case apply_type = "apply_type"
        case code = "code"
        case description_ar = "description_ar"
        case description_en = "description_en"
        case discount_type = "discount_type"
        case promo_for = "promo_for"
        case title_ar = "title_ar"
        case title_en = "title_en"
        case updatedAt = "updatedAt"
        case from = "from"
        case to = "to"
        case image_url = "image_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeSafely(String.self, forKey: .id)
        discount_value = values.decodeSafely(Float.self, forKey: .discount_value)
        status = values.decodeSafely(String.self, forKey: .status)
        apply_type = values.decodeSafely(String.self, forKey: .apply_type)
        code = values.decodeSafely(String.self, forKey: .code)
        description_ar = values.decodeSafely(String.self, forKey: .description_ar)
        description_en = values.decodeSafely(String.self, forKey: .description_en)
        discount_type = values.decodeSafely(String.self, forKey: .discount_type)
        promo_for = values.decodeSafely(String.self, forKey: .promo_for)
        title_ar = values.decodeSafely(String.self, forKey: .title_ar)
        title_en = values.decodeSafely(String.self, forKey: .title_en)
        updatedAt = values.decodeSafely(String.self, forKey: .updatedAt)
        from = values.decodeSafely(String.self, forKey: .from)
        to = values.decodeSafely(String.self, forKey: .to)
        image_url = values.decodeSafely(String.self, forKey: .image_url)

    }
    
}
