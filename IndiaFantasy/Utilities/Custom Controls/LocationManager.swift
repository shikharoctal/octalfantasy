//
//  LocationManager.swift
//  Lifferent
//
//  Created by sumit sharma on 22/01/21.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    let bannedStates = CommonFunctions.getStringItemFromInternalResourcesforKey(key: "BannedStates")
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var currentGeoStateCode = ""

    let locationManager = CLLocationManager()
    var addressString = ""
    var arrAddressLines = [String]()
    
    
    var isLocationPermissionOn:Bool {
        return ((CLLocationManager.authorizationStatus() == .authorizedAlways) || (CLLocationManager.authorizationStatus() == .authorizedWhenInUse))
    }
    
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager:CLLocationManagerDelegate {
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("MT | LOCATION SERVICES PAUSED!")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            print("latitude:\(latitude),longitude:\(longitude)")
            let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { (placemarksArray, error) in
                    if let placemarksArray = placemarksArray{
                        if (error) == nil {
                            print(placemarksArray)
                            if placemarksArray.count > 0 {
                                let placemark = placemarksArray[0]
                                let address = "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                                if let state = placemark.administrativeArea{
                                    self.currentGeoStateCode = state
                                }
                                print("\(address)")
                                self.addressString = address
                            }
                        }
                    }
            }
            print("latitude:\(latitude),longitude:\(longitude)")

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Fail to update location error:\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print(".Authorized")
            break
        case .notDetermined, .restricted, .denied:
            print(".Denied")
            break
        default:
            print("Unhandled authorization status")
            break
        }
    }
    
    func isPLayingInLegalState() -> Bool{
//        var inLegalState = true
//        
//        if (self.currentGeoStateCode == ""){
//            inLegalState = false
//            Constants.kAppDelegate.showAlert(msg: ConstantMessages.kEnableLocationServices, isLogout: false, isLocationAlert: true)
//        }else if self.bannedStates.contains(self.currentGeoStateCode) == true{
//            inLegalState = false
//            Constants.kAppDelegate.showAlert(msg: ConstantMessages.kBannedLocationMessage, isLogout: false, isLocationAlert: false)
//
//        }
        
        return true
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ place: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}
