//
//  UserDefaultsCache.swift
//  Lifferent
//
//  Created by sumit sharma on 03/03/21.
//


import UIKit

///Singleton object of `UserDefaultsCache` class.
public let defaults = UserDefaultsCache()

///This class works as a middleware of Application and UserDefaults.
public class UserDefaultsCache{
    
    ///Keys to use with subscript operator of `UserDefaultsCache`.
    public enum Key: String{
        
        case userImage = "kuserImage"
        case selectedLanguage = "kselectedLanguage"
        case selectedSocialLogin = "kselectedSocialLogin"
        case videoCellType = "kvideoCellType"
        case fitbitConnectd = "kfitbitConnectd"
        case appleWatchConnectd = "kappleWatchConnectd"
        ///all objects of this enum.
        fileprivate static let all: [Key] = [.userImage,.selectedLanguage,.selectedSocialLogin,.videoCellType,.fitbitConnectd, .appleWatchConnectd]
    }
    
    
    ///instance of dictionary to cache UserDefaults values.
    private var cache = [Key: String]()
    
    ///initiliser to create instance of this class.
    fileprivate init(){
        Key.all.forEach{
            cache[$0] = UserDefaults.standard.string(forKey: $0.rawValue) ?? ""
        }
    }
    
    /**
     *   This method updates value of key to local cache and userDefaults.
     *   - parameters:
     *       - value: string value for this key.
     *       - key: key object to update.
     */
    public func set(value: String, forKey key: Key){
        cache[key] = value
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    ///subscript operator to get and set value for key.
    /// - parameters:
    ///     - key: key object to get/set value.
    public subscript(key: Key)->String{
        set(value){
            set(value: value, forKey: key)
        }
        get{ return cache[key] ?? "" }
    }
    
    /// get/set value of Push Notification setting to UserDefaults.
    public var isPushNotificationOn: Bool{
        set(value){
            UserDefaults.standard.set(value, forKey: "kNotification")
            UserDefaults.standard.synchronize()
        }
        
        get{
            if let value = UserDefaults.standard.object(forKey: "kNotification"){
                return value as! Bool
            }
            return true
        }
    }
    
    public var isAppLockOn: Bool{
        set(value){
            UserDefaults.standard.set(value, forKey: "kAppLock")
            UserDefaults.standard.synchronize()
        }
        
        get{
            if let value = UserDefaults.standard.object(forKey: "kAppLock"){
                return value as! Bool
            }
            return true
        }
    }
    
    public func removeDefaults(){
        cache.removeAll()
    }
    
}


