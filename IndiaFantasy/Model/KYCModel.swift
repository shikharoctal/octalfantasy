//
//  KYCModel.swift
//  IndiaFantasy
//
//  Created by Harendra Singh Rathore on 17/05/24.
//

import Foundation

// MARK: - Start KYC Response
struct StartKYCResponse: Codable {
    let name, phone, email, verificationID: String?
    let referenceID: Int?
    let formLink: String?
    let formStatus: String?

    enum CodingKeys: String, CodingKey {
        case name, phone, email
        case verificationID = "verification_id"
        case referenceID = "reference_id"
        case formLink = "form_link"
        case formStatus = "form_status"
    }
}
