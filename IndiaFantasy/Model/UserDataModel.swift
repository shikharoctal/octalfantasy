//
//  UserDataModel.swift

import UIKit
import ObjectiveC
import CoreData
import StoreKit

extension KeyedDecodingContainer {
    public func decodeSafely<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        return self.decodeSafely(T.self, forKey: key)
    }
    
    public func decodeSafely<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decode(Safe<T>.self, forKey: key)
        return decoded?.value
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        return self.decodeSafelyIfPresent(T.self, forKey: key)
    }
    
    public func decodeSafelyIfPresent<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer.Key) -> T? {
        let decoded = try? decodeIfPresent(Safe<T>.self, forKey: key)
        return decoded?.value
    }
    public struct Safe<Base: Decodable>: Decodable {
        public let value: Base?
        
        public init(from decoder: Decoder) throws {
            do {
                let container = try decoder.singleValueContainer()
                self.value = try container.decode(Base.self)
            } catch {
                //assertionFailure("ERROR: \(error)")
                // TODO: automatically send a report about a corrupted data
                self.value = nil
            }
        }
    }
}


extension AppDelegate {
    
    private struct AssociatedKey {
        static var user  = Constants.kAppDisplayName+"user"
    }
    public var user: UserDataModel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.user) as? UserDataModel
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKey.user, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

struct UserDataModel: Codable {
    let level, criket_level: Int?
    let permissions: [JSONAny]?
    let referred_amount: Double?
    let referred_amount_paid: Bool?
    let fb_id, full_name, account_holder_name, pan_name: String?
    let google_id: String?
    let apple_id: String?
    let otpverified, emailverified, mobileVerified: Bool?
    let bank_verified: Int?
    let bank_decline_reason, bank_name, branch, account_no, ifsc_code: String?
    let pan_verified: Int?
    let is_aadhar_verified: Bool?
    let pan_decline_reason, beneficiary_id: String?
    let deposit_amount, winngs_amount, bonus, free_cash: Double?
    let total_balance: Double?
    let rewards: [JSONAny]?
    let user_crypto_registered, user_crypto_verified: Bool?
    let id, country_code, phone, email: String?
    let username, first_name, last_name, password: String?
    let referred_by, referral_code, device_type, device_id: String?
    let user_type, status, createdAt, updatedAt: String?
    let v: Int?
    let address, city, country, dob: String?
    let gender, gstNo: String?
    let image: String?
    let pin_code, state, token: String?
    let wallet_address: String?
    let pan_image, bank_statement: String?
    let idnumber: String?
    let mnemonic, pan_number: String?
    let bank_state: String?
    let unUsedBoosterCount: Double?
    let isUsedReferral: Bool?
    let referralCommissionAmount: Double?
    let isAdminUser, chatBanStatus: Bool?
    
    let identity_verified : Int?
    let kyc_verified:Bool?
    
    enum CodingKeys: String, CodingKey {
        case level, full_name, account_holder_name
        case account_no, branch, bank_name, pan_number, ifsc_code, user_crypto_verified
        case criket_level = "criket_level"
        case permissions
        case referred_amount = "referred_amount"
        case referred_amount_paid = "referred_amount_paid"
        case fb_id = "fb_id"
        case free_cash = "free_cash"
        case google_id = "google_id"
        case apple_id = "apple_id"
        case otpverified, emailverified
        case bank_verified = "bank_verified"
        case bank_decline_reason = "bank_decline_reason"
        case pan_verified = "pan_verified"
        case pan_decline_reason = "pan_decline_reason"
        case beneficiary_id = "beneficiary_id"
        case deposit_amount = "deposit_amount"
        case winngs_amount = "winngs_amount"
        case is_aadhar_verified = "is_aadhar_verified"
        case bonus
        case pan_name
        case total_balance = "total_balance"
        case rewards
        case user_crypto_registered = "user_crypto_registered"
        case id = "_id"
        case country_code = "country_code"
        case phone, email, username
        case first_name = "first_name"
        case last_name = "last_name"
        case password
        case referred_by = "referred_by"
        case referral_code = "referral_code"
        case device_type = "device_type"
        case device_id = "device_id"
        case user_type = "user_type"
        case status, createdAt, updatedAt
        case v = "__v"
        case address, city, country, dob, gender, gstNo, image
        case pin_code = "pin_code"
        case state, token
        case wallet_address = "wallet_address"
        case pan_image = "pan_image"
        case bank_statement = "bank_statement"
        case idnumber = "id"
        case mnemonic
        case identity_verified = "identity_verified"
        case bank_state = "bank_state"
        case unUsedBoosterCount
        case isUsedReferral
        case referralCommissionAmount, isAdminUser, chatBanStatus
        case mobileVerified = "mobile_verified"
        case kyc_verified = "kyc_verified"
    }
    
    public func saveUser(_ data: Data) {
        do {
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.set(archivedData, forKey: "user")
        } catch { print(error) }
        
        UserDefaults.standard.synchronize()
    }
    
    public func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "auth_token")
        UserDefaults.standard.synchronize()
    }
    
    public static func getToken() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "auth_token")
        else {return nil}
             
        return token
    }
    
    public func saveMnemonic(_ token: String) {
        UserDefaults.standard.set(token, forKey: "mnemonic")
        UserDefaults.standard.synchronize()
    }
    
    public static func getMnemonic() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "mnemonic")
        else {return nil}
             
        return token
    }
    
    public static func isLoggedIn() -> UserDataModel? {
        guard let unarchivedObject = UserDefaults.standard.data(forKey: "user")
        else {return nil}
        guard let unarchivedData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unarchivedObject) as? Data
        else {return nil}
        guard let user = decode(data: unarchivedData)
        else {return nil}
        
        return user
    }
    
    public func setRememberMeEnabled(_ isEnabled: Bool) {
        UserDefaults.standard.set(isEnabled, forKey: "remember_me")
        UserDefaults.standard.synchronize()
    }
    
    public static func getRememberMeEnabled() -> Bool? {
        if UserDefaults.standard.bool(forKey: "remember_me"){
            let isEnabled = UserDefaults.standard.bool(forKey: "remember_me")
            return isEnabled

        }
        return false
    }

    
    private static func decode(data: Data) -> UserDataModel? {
        return try? JSONDecoder().decode(UserDataModel.self, from: data)
    }
    
    private static func decodeToken(data: Data) -> String? {
        return try? JSONDecoder().decode(String.self, from: data)
    }
}



struct UpdateProfileModel : Codable {
    
    let result : UserDataModel?
    let success:Bool?
    let msg:String?
  
    enum CodingKeys: String, CodingKey {
        case result = "result"
        case success = "success"
        case msg = "msg"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        result = values.decodeSafely(UserDataModel.self, forKey: .result)
        success = values.decodeSafely(Bool.self, forKey: .success)
        msg = values.decodeSafely(String.self, forKey: .msg)
    }
}

struct Friend : Codable {
    
    let  first_name, id, image, last_name: String?
    let  referred_amount, referred_amount_paid: Double?

    enum CodingKeys: String, CodingKey {
        case first_name = "first_name"
        case id = "id"
        case image = "image"
        case last_name = "last_name"
        case referred_amount = "referred_amount"
        case referred_amount_paid = "referred_amount_paid"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        first_name = values.decodeSafely(String.self, forKey: .first_name)
        id = values.decodeSafely(String.self, forKey: .id)
        image = values.decodeSafely(String.self, forKey: .image)
        last_name = values.decodeSafely(String.self, forKey: .last_name)
        referred_amount = values.decodeSafely(Double.self, forKey: .referred_amount)
        referred_amount_paid = values.decodeSafely(Double.self, forKey: .referred_amount_paid)
    }
}

struct Pancard: Codable {
    let success: Bool?
    let msg: JSONAny?
    let auth: Bool?
    let errors: JSONAny?
    let isDeactivate: JSONAny?
    let results: PanDetails?
}

struct NationalId: Codable {
    let success: Bool?
    let msg: JSONAny?
    let errors: JSONAny?
    let results: JSONAny?
}

struct PanDetails: Codable {
    let age: Int?
    let dateOfBirth, dateOfIssue, fathersName, idNumber: String?
    let isScanned, minor: Bool?
    let nameOnCard, panType: String?

    enum CodingKeys: String, CodingKey {
        case age
        case dateOfBirth = "date_of_birth"
        case dateOfIssue = "date_of_issue"
        case fathersName = "fathers_name"
        case idNumber = "id_number"
        case isScanned = "is_scanned"
        case minor
        case nameOnCard = "name_on_card"
        case panType = "pan_type"
    }
}

// MARK: - Current Address
class userCurrentAddress {
    
    var userAddress: String?
    var userLocality: String?
    var latitude: Double?
    var longitude: Double?
}


class JSONAny: Codable {
    var value: Any
    
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
class JSONCodingKey: CodingKey {
    let key: String
    
    required init?(intValue: Int) {
        return nil
    }
    
    required init?(stringValue: String) {
        key = stringValue
    }
    
    var intValue: Int? {
        return nil
    }
    
    var stringValue: String {
        return key
    }
}

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
