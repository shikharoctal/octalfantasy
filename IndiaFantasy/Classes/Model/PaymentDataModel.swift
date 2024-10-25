//
//  UserDataModel.swift

import UIKit
import ObjectiveC
import CoreData
import StoreKit

struct Result : Codable {
    let orderId: String
    let referenceId: String
    let orderAmount: String
    let txStatus: String
    let txMsg: String
    let txTime: String
    let paymentMode: String
    let signature: String
    
    enum CodingKeys : String, CodingKey {
        case orderId
        case referenceId
        case orderAmount
        case txStatus
        case txMsg
        case txTime
        case paymentMode
        case signature
    }
}


struct PointSystem : Codable {
    let match_type: String
    let othersCaptain: Float
    let othersViceCaptain: Float
   
    
    enum CodingKeys : String, CodingKey {
        case match_type
        case othersCaptain
        case othersViceCaptain
    }
}


struct CouponDetails: Codable {
    var minDiscount, maxDiscount, cashbackPercent, usageLimit, flat_discount: Double?
    var limitPerUser: Int?
    var id, couponCode, status, createdAt, description: String?
    var updatedAt, type: String?
    var v: Int?
    var endDate, startDate, resultsID: String?

    enum CodingKeys: String, CodingKey {
        case minDiscount = "min_discount"
        case maxDiscount = "max_discount"
        case cashbackPercent = "cashback_percent"
        case usageLimit = "usage_limit"
        case limitPerUser = "limit_per_user"
        case id = "_id"
        case couponCode = "coupon_code"
        case status, description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case endDate = "end_date"
        case startDate = "start_date"
        case resultsID = "id"
        case type
        case flat_discount

    }
}

// MARK: - Doc
struct WithDrawHistoryModel: Codable {
    let id: String?
    let totalBalance: Double?
    let requestedAmount: Double?
    let remainingAmount: Double?
    let reason, reasonText, name: String?
    let userID: UserDetails?
    let email, phone, type, status: String?
    let createdAt, updatedAt: String?
    let v: Int?
    let docID: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case totalBalance = "total_balance"
        case requestedAmount = "requestedAmount"//"requested_amount"
        case remainingAmount = "remaining_amount"
        case reason
        case reasonText = "reason_text"
        case name
        case userID = "user_id"
        case email, phone, type, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case v = "__v"
        case docID = "id"
    }
}

// MARK: - UserID
struct UserDetails: Codable {
    let id, fullName: String?
    let bankVerified: Int?
    let bankDeclineReason: String?
    let panVerified: Int?
    let panDeclineReason, phone, email, firstName: String?
    let lastName, panImage, panName, panNumber: String?
    let accountNo, bankName, branch, ifscCode: String?
    let image, bankStatement: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case fullName = "full_name"
        case bankVerified = "bank_verified"
        case bankDeclineReason = "bank_decline_reason"
        case panVerified = "pan_verified"
        case panDeclineReason = "pan_decline_reason"
        case phone, email
        case firstName = "first_name"
        case lastName = "last_name"
        case panImage = "pan_image"
        case panName = "pan_name"
        case panNumber = "pan_number"
        case accountNo = "account_no"
        case bankName = "bank_name"
        case branch
        case ifscCode = "ifsc_code"
        case image
        case bankStatement = "bank_statement"
    }
}

struct TaxInfo : Codable {
    
    let bonus, gstAmount, gstPercantage, calculatedAmount: String?
    let totalAmount: String?
    
    enum CodingKeys: String, CodingKey {
        case bonus
        case gstAmount = "gst_amount"
        case gstPercantage = "gst_percantage"
        case calculatedAmount = "calculated_amount"
        case totalAmount = "total_amount"
    }
}
