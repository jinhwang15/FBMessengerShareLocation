//
//  LandingViewController.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 16/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

//MARK: - IMPORTS -

import UIKit
import CoreLocation
import MapKit

//MARK: - BEGİNNİNG OF SUPERCLASS -

class LandingViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, SelectedDelegate {

//MARK: - Variables and IBOutlets -
    
    @IBOutlet var dateTextView: UITextView!
    
    var updateLocationCount = 0;
    
    @IBOutlet var userAddressLabel: UILabel!
    
    @IBOutlet var currentLocationView: UIView!
    
    @IBOutlet var mapView: MKMapView!
    
    var datePickerAccessoryView: UIView!
    
    var datePickerView: UIView!
    
    var dimView: UIButton!
    
    var pickerDoneButton: UIButton!
    
    var pickerCancelButton: UIButton!
    
    var datePickerComponent: UIDatePicker!
    
    var DateInFormat:String="";
    
    var lastLocation: CLLocation!
    
    let locationManager = CLLocationManager()
    var userName: String = "";
    var userEmail: String = "";
    var locationStatus: String = "";
    var addressString : String = ""

    
    
// MARK: - Selected Delegate Method -
    
    func locationSelected(selectedLocation: CLLocation!) {
     
     lastLocation=selectedLocation
    
    locationManager.stopUpdatingLocation()
    
    addAnnotation()
    
    findAddress()
    
    }
        
// MARK: - Lifecycle  -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set Navigation Controller as Hidden
        self.navigationController?.navigationBarHidden=false;
        // hide back Button
        self.navigationItem.hidesBackButton=true;
        
        // set userName as Navigation Title
        self.navigationItem.title=userName;
        
        
        initializeDatePickerInputView()
        
        
        createFBSDKMessengerButton()
        
        initializeLocationManager()
        
        // Do any additional setup after loading the view.
        
        self.mapView.delegate=self;
        
    }
    
// MARK: - Preparing Components and Objects -
    
    func initializeLocationManager()
    {
     
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter=kCLLocationAccuracyNearestTenMeters
        
        
    }
    
    func initializeDatePickerInputView()
    {
        
        self.datePickerComponent=UIDatePicker()
        
        self.datePickerAccessoryView=UIView()
        
        self.dimView=UIButton(frame: UIScreen.mainScreen().bounds)
        self.dimView.backgroundColor=UIColor.blackColor()
        self.dimView.alpha=0.7
        
        self.dimView.addTarget(self, action:"pickerCancelButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        
        // picker done button
        
        self.pickerDoneButton=UIButton()
        
        self.pickerDoneButton.setTitle("Pick", forState: UIControlState.Normal)
        
        self.pickerDoneButton.addTarget(self, action:"pickerDoneButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        self.datePickerAccessoryView.addSubview(self.pickerDoneButton)
        
        // picker cancel button
        
        self.pickerCancelButton=UIButton(frame: CGRectMake(self.datePickerAccessoryView.frame.origin.x, 0, 50, self.datePickerAccessoryView.frame.size.height))
        
        self.pickerCancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        
        self.pickerCancelButton.addTarget(self, action:"pickerCancelButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        self.datePickerAccessoryView.addSubview(self.pickerCancelButton)
        
        
        self.datePickerView=UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 210))
        
        self.datePickerView.addSubview(self.datePickerComponent)
        self.datePickerView.addSubview(self.datePickerAccessoryView);
        
        self.datePickerAccessoryView.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50)
        
        self.datePickerComponent.frame=CGRectMake(0, self.datePickerAccessoryView.frame.size.height, UIScreen.mainScreen().bounds.size.width, 160)
        
        self.pickerDoneButton.frame=CGRectMake(self.datePickerAccessoryView.frame.size.width - 50, 0, 50, self.datePickerAccessoryView.frame.size.height)
        
        self.pickerCancelButton.frame=CGRectMake(0, 0, 60, self.datePickerAccessoryView.frame.size.height)
        
        // date parametresi dönen metod
        
        var todaysDate:NSDate = NSDate()
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        DateInFormat = NSDateFormatter.localizedStringFromDate(todaysDate, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        datePickerComponent.minimumDate=todaysDate
        
        // set TextField's input view and accessory view
        dateTextView.inputView=self.datePickerView
        
        dateTextView.tintColor=UIColor .clearColor()
        
        // dateTextView.inputAccessoryView=self.datePickerAccessoryView
        
        dateTextView.text=DateInFormat
        
        datePickerComponent .setDate(todaysDate, animated: false)
        
    }
    func createFBSDKMessengerButton() {
        
        var fbBtn = FBSDKMessengerShareButton.rectangularButtonWithStyle(.Blue)
        fbBtn.addTarget(self, action: "_shareButtonPressed:" , forControlEvents: .TouchUpInside)
        //setting for fbBtn if needed
        self.view.addSubview(fbBtn)
        
        fbBtn.frame=CGRectMake(self.view.frame.origin.x + 30, self.view.frame.size.height - 70, 260, 50)
    }
    


// MARK: - Date Picker Accessory View Button Actions -
    
    func pickerDoneButtonTouched(sender:UIButton!)
    {
        
        DateInFormat = NSDateFormatter.localizedStringFromDate(datePickerComponent.date, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        dateTextView.text = DateInFormat
        
        userAddressLabel.text="Hi, I am at "+addressString + " at "+DateInFormat;
        
        self.dateTextView.resignFirstResponder()
    }
    func pickerCancelButtonTouched(sender:UIButton!)
    {
        self.dateTextView.resignFirstResponder()
        
    }
    
// MARK: - Text View Delegate Methods -
    
    func textViewDidEndEditing(textView: UITextView) {
        if(self.dimView.isDescendantOfView(self.view))
        {
            self.dimView.removeFromSuperview()
        }
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
       
    
      if(self.dimView.isDescendantOfView(self.view))
        {
           self.dimView.removeFromSuperview()
        }
        
           self.view.addSubview(self.dimView)
    }
    
  
//MARK: - MKMapView Delegate Methods -
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinColor = .Red
            pinAnnotationView.draggable = false
            pinAnnotationView.canShowCallout = false
            pinAnnotationView.animatesDrop = true
            pinAnnotationView.enabled=false
            
            return pinAnnotationView
        }
 
        return nil
    }
    
// MARK: - CLLocationManager Delegate Methods -
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
     
        switch status {
        case CLAuthorizationStatus.Restricted:
            locationStatus = "Access: Restricted"
            locationManager.requestWhenInUseAuthorization()
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
        
        lastLocation = locations.last as! CLLocation
    
        addAnnotation()

        findAddress()
        
      }
    
    
// TODO: - CREATE ANOTHER CLASS FOR THESE METHODS -    
    func findAddress()
    {
        
        CLGeocoder().reverseGeocodeLocation(lastLocation, completionHandler: {(placemarks, error)->Void in
            
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
    
    func addAnnotation()
    
    {
        let center = CLLocationCoordinate2D(latitude:self.lastLocation.coordinate.latitude, longitude: self.lastLocation.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)

        if(self.mapView.annotations.count>0) {
            
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = center
        self.mapView.addAnnotation(objectAnnotation)
    }
    
    
    
    func getLocationAddress(placemark : CLPlacemark) {
        
        
        if (!addressString.isEmpty)
        {
            addressString.removeAll(keepCapacity: true)
        }
        
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
    
// MARK: - FBSDKMessengerShare Action Method -
    
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
    

// MARK: - Navigation -

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
    // Get the new view controller using segue.destinationViewController.
        if (segue.identifier == "mapSegue")
        {
            var chooseLocationViewController = segue.destinationViewController as! ChooseLocationViewController;
        
            chooseLocationViewController.selectedLocationDelegate=self;
        
            // Pass the user data to the new view controller.
            if (self.lastLocation != nil)
            {
                chooseLocationViewController.selectedLocation = lastLocation as CLLocation;
            }
        }
    }
    
//MARK: - END OF SUPERCLASS -
}
