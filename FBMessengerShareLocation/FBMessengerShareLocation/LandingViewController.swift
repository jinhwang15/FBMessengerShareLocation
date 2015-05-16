//
//  LandingViewController.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 16/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

import UIKit
import CoreLocation

class LandingViewController: UIViewController, CLLocationManagerDelegate  {
// account data
    @IBOutlet var userNameLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userName: String = "";
    var userEmail: String = "";
    var locationStatus: String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameLabel.text=userName;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
     
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Access: Restricted"
            break
        case CLAuthorizationStatus.Denied:
            locationStatus = "Access: Denied"
            break
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Access: NotDetermined"
            break
        default:
            locationStatus = "Access: Allowed"
            locationManager.startUpdatingLocation()

        }
        NSLog(locationStatus)

    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                self.getLocationAddress(pm)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func getLocationAddress(placemark : CLPlacemark) {
        
        println("-> Finding user address...")
        
                
                var addressString : String = ""
                if placemark.ISOcountryCode == "TW" /*Address Format in Chinese*/ {
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
            }

//    func shareImage() {
//        
//        let result = FBSDKMessengerSharer.messengerPlatformCapabilities().rawValue & FBSDKMessengerPlatformCapability.Image.rawValue
//        if result != 0 {
//            // ok now share
//            if let sharingImage = sharingImage {
//                FBSDKMessengerSharer.shareImage(sharingImage, withOptions: nil)
//            }
//        } else {
//            // not installed then open link. Note simulator doesn't open iTunes store.
//            UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8")!)
//        }
//        
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
