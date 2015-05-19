//
//  GettingAddressInfoService.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 19/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation
{
    func getLocationAddress(placemark : CLPlacemark) -> String {
        
        var addressString : String
        
        addressString=""
        
        println("-> Finding user address...")
        
        if placemark.ISOcountryCode == "TW" {
            if placemark.country != nil {
                addressString = placemark.country
            }
            if placemark.subAdministrativeArea != nil {
                addressString = addressString + placemark.subAdministrativeArea + ", "
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode + " "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare
            }
            if placemark.subThoroughfare != nil {
                addressString = addressString + placemark.subThoroughfare
            }
        } else {
            if placemark.subThoroughfare != nil {
                addressString = placemark.subThoroughfare + " "
            }
            if placemark.thoroughfare != nil {
                addressString = addressString + placemark.thoroughfare + ", "
            }
            if placemark.postalCode != nil {
                addressString = addressString + placemark.postalCode + " "
            }
            if placemark.locality != nil {
                addressString = addressString + placemark.locality + ", "
            }
            if placemark.administrativeArea != nil {
                addressString = addressString + placemark.administrativeArea + " "
            }
            if placemark.country != nil {
                addressString = addressString + placemark.country
            }
        }
        
        println(addressString)
        
        return addressString
        
        
    }
    
    
    
}

