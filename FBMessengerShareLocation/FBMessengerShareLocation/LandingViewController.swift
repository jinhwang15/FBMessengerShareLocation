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
class LandingViewController: UIViewController, CLLocationManagerDelegate, UITextViewDelegate, MKMapViewDelegate, SelectedDelegate
{
    
//MARK: - Variables and IBOutlets -
    @IBOutlet var dateTextView: UITextView!        // Text View to show date
    @IBOutlet var userAddressLabel: UILabel!       // Label to show current address info
    @IBOutlet var currentLocationView: UIView!     // UIView to create UIImage and share
    @IBOutlet var mapView: MKMapView!              // MapView to Show Location
    var dimButton: UIButton!                         // UIButton to close DatePicker
    var pickerDoneButton: UIButton!                // UIButton to close DatePicker and get picked Value from DatePicker
    var pickerCancelButton: UIButton!              // UIButton to close DatePicker
    var datePickerComponent: UIDatePicker!         // UIDatePicker to pick date
    var selectedDate:NSDate!                       // NSDate to hold picked date
    var datePickerAccessoryView: UIView!
    var datePickerView: UIView!
    var userFullName: String = "";                 // Logged-in user's FullName
    var addressString : String = ""                // Latest Address Value
    let locationManager = CLLocationManager()
    var lastLocation: CLLocation!                  // Latest updated Location Value
    var loadingAnimation : UIActivityIndicatorView!
    
    
// MARK: - Selected Delegate Method -
    func locationSelected(selectedLocation: CLLocation!)
    {
        lastLocation=selectedLocation
        locationManager.stopUpdatingLocation()
        addAnnotation()
        findAddress()
    }
        
// MARK: - Lifecycle  -
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // set Navigation Controller as Hidden
        self.navigationController?.navigationBarHidden=false;
        // hide back Button
        self.navigationItem.hidesBackButton=true;
        // set userName as Navigation Title
        self.navigationItem.title=userFullName;
        
        initializeComponents()
        createFBSDKMessengerButton()
        initializeLocationManager()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
    }
// MARK: - Preparing Components and Objects -
    func initializeLocationManager()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.distanceFilter=kCLLocationAccuracyNearestTenMeters
    }
    
    func initializeComponents()
    {
        initializeMapView()
        initializeDimView()
        initializeDatePickerInputView()
        initializeDatePickerAccessoryView()
        initializeDatePickerComponent()
        initializeDatePickerAccessoryInputViewButtons()
        
        // Activity Indicator initialize
        loadingAnimation = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingAnimation.center=self.view.center
        loadingAnimation.hidesWhenStopped=true
        self.view.addSubview(loadingAnimation)
    }
    func initializeMapView()
    {
        self.mapView.delegate=self
        self.mapView.scrollEnabled=false
        self.mapView.showsUserLocation=false
        self.mapView.showsBuildings=false
    }
    func initializeDatePickerInputView()
    {

        self.datePickerView=UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 210))
        // set TextField's input view and accessory view
        self.dateTextView.inputView=self.datePickerView
        self.dateTextView.tintColor=UIColor .clearColor()
            
    }
    func initializeDatePickerAccessoryView()
    {

        self.datePickerAccessoryView=UIView()
        self.datePickerAccessoryView.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50)
        self.datePickerView.addSubview(self.datePickerAccessoryView);
    
    }

    func initializeDimView()
    {

        
        // covers self.view when datePickerComponent is enabled
        self.dimButton=UIButton(frame: UIScreen.mainScreen().bounds)                              // dim View frame
        self.dimButton.backgroundColor=UIColor.blackColor()                                       // set Background as blackColor
        self.dimButton.alpha=0.5                                                                  // set Alpha as 0.5
        self.dimButton.addTarget(self, action:"pickerCancelButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)                                                      // dim View assigning target
    }
    
    func initializeDatePickerAccessoryInputViewButtons()
    {

            // picker done button
        self.pickerDoneButton=UIButton()
        self.pickerDoneButton.setTitle("Pick", forState: UIControlState.Normal)
        self.pickerDoneButton.addTarget(self, action:"pickerDoneButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        self.datePickerAccessoryView.addSubview(self.pickerDoneButton)
        self.pickerDoneButton.frame=CGRectMake(self.datePickerAccessoryView.frame.size.width - 50, 0, 50, self.datePickerAccessoryView.frame.size.height)
        
    // picker cancel button
        self.pickerCancelButton=UIButton(frame: CGRectMake(self.datePickerAccessoryView.frame.origin.x, 0, 50, self.datePickerAccessoryView.frame.size.height))
        self.pickerCancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        self.pickerCancelButton.addTarget(self, action:"pickerCancelButtonTouched:", forControlEvents: UIControlEvents.TouchUpInside)
        self.datePickerAccessoryView.addSubview(self.pickerCancelButton)
        self.pickerCancelButton.frame=CGRectMake(0, 0, 60, self.datePickerAccessoryView.frame.size.height)

    }
    
    func initializeDatePickerComponent()
    {
        self.datePickerComponent=UIDatePicker()
        self.datePickerView.addSubview(self.datePickerComponent)
        self.datePickerComponent.frame=CGRectMake(0, self.datePickerAccessoryView.frame.size.height, UIScreen.mainScreen().bounds.size.width, 160)
        selectedDate=NSDate()
        var dateFormatter:NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        dateTextView.text=NSDateFormatter.localizedStringFromDate(selectedDate, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        
        datePickerComponent.minimumDate=selectedDate
        datePickerComponent .setDate(selectedDate, animated: false)
    }
    
    func createFBSDKMessengerButton()
    {

        var shareButton = FBSDKMessengerShareButton.rectangularButtonWithStyle(.Blue) // Create a FBSDKMessengerShareButton instance as Share Button
        
        shareButton.addTarget(self, action: "_shareButtonPressed:" , forControlEvents: .TouchUpInside) // add Target to Share Button
        self.view.addSubview(shareButton)
        shareButton.frame=CGRectMake((self.view.frame.size.width - 267) / 2 , self.view.frame.size.height - 70, 267, 50)
    }
// MARK: - Date Picker Accessory View Button Actions -
    
    func dateComparison(addressString : String)
    {
        if selectedDate.isGreaterThanDate(NSDate())==true
        {
            userAddressLabel.text="Hi, I will be at "+addressString + " on "+NSDateFormatter.localizedStringFromDate(selectedDate, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle);
        }
        else
        {
            userAddressLabel.text="Hi, I am at "+addressString + " on "+NSDateFormatter.localizedStringFromDate(selectedDate, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle);
        }
    }
    
    func pickerDoneButtonTouched(sender:UIButton!)
    {
        selectedDate=datePickerComponent.date
        dateTextView.text = NSDateFormatter.localizedStringFromDate(datePickerComponent.date, dateStyle: NSDateFormatterStyle.LongStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
        dateComparison(addressString)
        self.dateTextView.resignFirstResponder()
    }
    
    func pickerCancelButtonTouched(sender:UIButton!)
    {
        self.dateTextView.resignFirstResponder()
    }
    
// MARK: - Text View Delegate Methods -
    
    func textViewDidEndEditing(textView: UITextView)
    {
        if(self.dimButton.isDescendantOfView(self.view))
        {
            self.dimButton.removeFromSuperview()
        }
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        datePickerComponent.reloadInputViews()
        datePickerComponent.setDate(selectedDate , animated: false)
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        if(self.dimButton.isDescendantOfView(self.view))
        {
           self.dimButton.removeFromSuperview()
        }
        self.view.addSubview(self.dimButton)
    }
    
//MARK: - MKMapView Delegate Methods -
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        if annotation is MKPointAnnotation
        {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            // set pinAnnotationView settings
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
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        var locationStatus: String = "";
        switch status      // There is no need to put break in Swift

        {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Access: Restricted"
                locationManager.requestWhenInUseAuthorization()
            
            case CLAuthorizationStatus.Denied:
                locationStatus = "Access: Denied"
                locationManager.requestWhenInUseAuthorization()
            
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Access: NotDetermined"
                locationManager.requestWhenInUseAuthorization()

            default:
                locationStatus = "Access: Allowed"
                locationManager.startUpdatingLocation()
        }
        NSLog(locationStatus)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println("Error while updating location " + error.localizedDescription)
        
        if(error==kCLErrorDomain)
        {
            userAddressLabel.text="Please turn on your Location Services"
        }
        else
        {
            userAddressLabel.text="Couldn't find location..."
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        lastLocation = locations.last as! CLLocation
        addAnnotation()
        findAddress()
    }
    
//MARK: - Reverse Geocoding Call -
    func findAddress()
    { 
        CLGeocoder().reverseGeocodeLocation(lastLocation, completionHandler:
        {(placemarks, error) -> Void in
                if (error != nil)
                {
                    println("Reverse geocoder failed with error" + error.localizedDescription)
                    self.addressString = "Couldn't find address."
                }
                else
                {
                    if placemarks.count > 0
                    {
                        let pm = placemarks[0] as! CLPlacemark
                        self.addressString = self.lastLocation.getLocationAddress(pm)
                        println(self.addressString)
                        self.dateComparison(self.addressString)
                        
                    }
                    else
                    {
                        println("Problem with the data received from geocoder")
                        self.addressString = "Couldn't find address."
                    }
                    
                }
                self.loadingAnimation.stopAnimating()
        })
    }
//MARK: - Add Annotation to Map View -
    
    func addAnnotation()
    {
        loadingAnimation.startAnimating()
        
        let center = CLLocationCoordinate2D(latitude:self.lastLocation.coordinate.latitude, longitude: self.lastLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        if(self.mapView.annotations.count>0)
        {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = center
        self.mapView.addAnnotation(objectAnnotation)
    }
// MARK: - FBSDKMessengerShare Action Method -
    
    @IBAction func _shareButtonPressed(sender: AnyObject)
    {
        
        if(lastLocation != nil)
        {
            let result = FBSDKMessengerSharer.messengerPlatformCapabilities().rawValue & FBSDKMessengerPlatformCapability.Image.rawValue
            if result != 0
            {
                // ok now share
                UIGraphicsBeginImageContext(self.currentLocationView.bounds.size);
            self.currentLocationView.drawViewHierarchyInRect(self.currentLocationView.bounds, afterScreenUpdates: true)
                var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
            
                UIGraphicsEndImageContext();
            
                var sharingImage: UIImage
            
                sharingImage = image;
            
                FBSDKMessengerSharer.shareImage(sharingImage, withOptions:nil)
            }
            else
            {
                // not installed then open link. Note simulator doesn't open iTunes store.
                UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/facebook-messenger/id454638411?mt=8")!)
            }
        }
        else
        {
            let alertView = UIAlertController(title:"Error", message:"Sorry, no location data to share", preferredStyle: .Alert)
            
            alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            
            presentViewController(alertView, animated: true, completion: nil)
            
        }
    }
    
// MARK: - Navigation -
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
