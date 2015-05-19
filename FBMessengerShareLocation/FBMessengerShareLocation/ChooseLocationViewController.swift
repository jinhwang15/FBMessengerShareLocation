//
//  ChooseLocationViewController.swift
//  FBMessengerShareLocation
//
//  Created by Mustafa Sait Demirci on 17/05/15.
//  Copyright (c) 2015 msdeveloper. All rights reserved.
//

//MARK: - IMPORTS -
import UIKit
import CoreLocation
import MapKit
//MARK: - Assigning Selected Delegate -
protocol SelectedDelegate : class {
    func locationSelected(selectedLocation:CLLocation!)
}
//MARK: - BEGİNNİNG OF SUPERCLASS -
class ChooseLocationViewController: UIViewController, MKMapViewDelegate {
    
//MARK: - Variables,IBOutlets -

    @IBOutlet var mapView: MKMapView!
    
    var objectAnnotation = MKPointAnnotation()

     weak var selectedLocationDelegate:SelectedDelegate?
    var addressString : String=""
    var selectedLocation: CLLocation?
  
//MARK: - LifeCycle -

    override func viewDidDisappear(animated: Bool) {
        
        // There is a general bug releasing mapview cache
        
        self.mapView.removeFromSuperview()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var center:CLLocationCoordinate2D
        
        if(self.selectedLocation != nil)
        {
            center = CLLocationCoordinate2D(latitude:self.selectedLocation!.coordinate.latitude, longitude: self.selectedLocation!.coordinate.longitude)
        }
        else
        {
            
            center = CLLocationCoordinate2D(latitude:37.3316309, longitude:-122.029584)
        }
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        if(self.mapView.annotations.count>0) {
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            
        }
        
        objectAnnotation.coordinate = center
        objectAnnotation.title = "Hold on for a while and Drag me"
        self.mapView.addAnnotation(objectAnnotation)
        
        // Do any additional setup after loading the view.
    }

//MARK: - MKMapViewDelegate Methods -
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == MKAnnotationViewDragState.Ending {
            let ann = view.annotation
            println("annotation dropped at: \(ann.coordinate.latitude),\(ann.coordinate.longitude)")
            
            self.selectedLocation=CLLocation(latitude: ann.coordinate.latitude, longitude: ann.coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(self.selectedLocation, completionHandler: {(placemarks, error)->Void in
                
                if (error != nil) {
                    println("Reverse geocoder failed with error" + error.localizedDescription
                    )
                    self.objectAnnotation.title="Couldn't find address info...";
                    
                    return
                }
                
                if placemarks.count > 0 {
                    let pm = placemarks[0] as! CLPlacemark
                    self.getLocationAddress(pm)
                } else {
                    
                    self.objectAnnotation.title="Couldn't find address info...";
                    
                    println("Problem with the data received from geocoder")
                }
            })
            
        }
    }

    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinColor = .Purple
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            return pinAnnotationView
        }
        
        return nil
    }

//MARK - Pick and Cancel Button Actions -
    
    @IBAction func cancelButtonTouched(sender: UIButton) {
        
        self .dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func selectLocationButtonTouched(sender: UIButton) {
        
        
        if self.selectedLocation != nil
        {
            selectedLocationDelegate?.locationSelected(selectedLocation)
        }
        self .dismissViewControllerAnimated(true, completion: nil)
        
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
        
        objectAnnotation.title=addressString
        
        
    }
    
//MARK: - END OF SUPERCLASS -
}
