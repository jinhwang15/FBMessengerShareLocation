//
//  LandingViewController.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 16/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LandingViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate  {
// account data
    
    
    @IBOutlet var changeTimeTextField: UITextField!
    
    @IBOutlet var userAddressLabel: UILabel!
    
    @IBOutlet var currentLocationView: UIView!
    
    @IBOutlet var mapView: MKMapView!
    
    var datePickerAccessoryView: UIView!
    
    var datePickerView: UIView!
    
    var datePickerComponent: UIDatePicker!
    
    var DateInFormat:String="";
    
    let locationManager = CLLocationManager()
    var userName: String = "";
    var userEmail: String = "";
    var locationStatus: String = "";
    var addressString : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // set Navigation Controller as Hidden
        self.navigationController?.navigationBarHidden=false;
        self.navigationItem.hidesBackButton=true;
        
        self.navigationItem.title=userName;
        
        
        //initializing
        
        self.datePickerComponent=UIDatePicker(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 220))
        
        self.datePickerAccessoryView=UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 60))
        
        
        
        self.datePickerView=UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 220))

       self.datePickerView.addSubview(self.datePickerComponent)
        
        // date parametresi dönen metod
        
        var todaysDate:NSDate = NSDate()
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy"
        
        DateInFormat = dateFormatter.stringFromDate(todaysDate)
        
        // set TextField's input view and accessory view
        changeTimeTextField.inputView=self.datePickerView
        
       changeTimeTextField.inputAccessoryView=self.datePickerAccessoryView

        changeTimeTextField.text=DateInFormat
        
        datePickerComponent .setDate(todaysDate, animated: false)
        
        createFBSDKMessengerButton()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createFBSDKMessengerButton() {
        
        var fbBtn = FBSDKMessengerShareButton.rectangularButtonWithStyle(.Blue)
        fbBtn.addTarget(self, action: "_shareButtonPressed:" , forControlEvents: .TouchUpInside)
        //setting for fbBtn if needed
        self.view.addSubview(fbBtn)
        
        fbBtn.frame=CGRectMake(self.view.frame.origin.x + 30, self.view.frame.size.height - 70, 260, 50)
    }
    
    @IBAction func _shareButtonPressed(sender: AnyObject) {
        let result = FBSDKMessengerSharer.messengerPlatformCapabilities().rawValue & FBSDKMessengerPlatformCapability.Image.rawValue
        if result != 0 {
            // ok now share
            
            UIGraphicsBeginImageContext(self.currentLocationView.bounds.size);
            
            self.currentLocationView.drawViewHierarchyInRect(self.currentLocationView.bounds, afterScreenUpdates: true)
            var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            var sharingImage: UIImage
            
            sharingImage = image;
            
            FBSDKMessengerSharer.shareImage(sharingImage, withOptions:nil)
            
        } else {
            // not installed then open link. Note simulator doesn't open iTunes store.
            UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8")!)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
     
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Access: Restricted"
            break
        case CLAuthorizationStatus.Denied:
            locationStatus = "Access: Denied"
            locationManager.requestWhenInUseAuthorization()

            break
        case CLAuthorizationStatus.NotDetermined:
            locationStatus = "Access: NotDetermined"
            locationManager.requestWhenInUseAuthorization()

            break
        default:
            locationStatus = "Access: Allowed"
            locationManager.startUpdatingLocation()

        }
        NSLog(locationStatus)

    }
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
        
        userAddressLabel.text="Couldn't find location...";

    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = center

        objectAnnotation.title = addressString
        self.mapView.addAnnotation(objectAnnotation)
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription
                )
            self.userAddressLabel.text="Couldn't find location...";

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
        
        
        
        userAddressLabel.text="Hi, I am at "+addressString + " at "+DateInFormat;
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
