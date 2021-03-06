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
protocol SelectedDelegate : class
{
    func locationSelected(selectedLocation:CLLocation!)
}

//MARK: - BEGİNNİNG OF SUPERCLASS -
class ChooseLocationViewController: UIViewController, MKMapViewDelegate {
    
//MARK: - Variables,IBOutlets -
    @IBOutlet var mapView: MKMapView!
    weak var selectedLocationDelegate:SelectedDelegate?
    var objectAnnotation = MKPointAnnotation()
    var addressString : String=""
    var selectedLocation: CLLocation?
    var loadingAnimation : UIActivityIndicatorView!

//MARK: - LifeCycle -
    override func viewDidDisappear(animated: Bool)
    {
        // There is a general bug releasing mapview cache
        applyMapViewMemoryHotFix()
    }
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var center:CLLocationCoordinate2D
        
        if(self.selectedLocation != nil)
        {
            center = CLLocationCoordinate2D(latitude:self.selectedLocation!.coordinate.latitude, longitude:self.selectedLocation!.coordinate.longitude)
        }
        else
        {
            center = CLLocationCoordinate2D(latitude:37.3316309, longitude:-122.029584)
            self.selectedLocation=CLLocation(latitude:center.latitude, longitude:center.longitude)
        }
        
        // Activity Indicator initialize
        loadingAnimation = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingAnimation.center=self.view.center
        loadingAnimation.hidesWhenStopped=true
        self.view.addSubview(loadingAnimation)
        
        addAnnotation(center)
        
        findAddress()
    }
    
//MARK: - MapView Memory Releasing -
    
    func applyMapViewMemoryHotFix()
    {
        switch (self.mapView.mapType) {
        
        case MKMapType.Standard:
        self.mapView.mapType = MKMapType.Hybrid
            
        default:
            break;
        }

        self.mapView.showsUserLocation = false;
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.delegate = nil;
        self.mapView.removeFromSuperview();
        self.mapView = nil;
    }
    
//MARK: - Add Annotation to Map View -
    
    func addAnnotation(center : CLLocationCoordinate2D)
    {
        loadingAnimation.startAnimating()

        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        if(self.mapView.annotations.count>0)
        {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        objectAnnotation.coordinate = center
        self.mapView.addAnnotation(objectAnnotation)
    }

//MARK: - MKMapViewDelegate Methods -
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState)
    {
        if newState == MKAnnotationViewDragState.Ending
        {
            let ann = view.annotation
            println("annotation dropped at: \(ann.coordinate.latitude),\(ann.coordinate.longitude)")
            self.selectedLocation=CLLocation(latitude: ann.coordinate.latitude, longitude: ann.coordinate.longitude)
            
            findAddress()
            
        }
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!
    {
        if annotation is MKPointAnnotation
        {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinAnnotationView.pinColor = .Purple
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        return nil
     }

    func findAddress()
    {
        CLGeocoder().reverseGeocodeLocation(self.selectedLocation, completionHandler:
            {(placemarks, error)->Void in
                if (error != nil)
                {
                    println("Reverse geocoder failed with error" + error.localizedDescription)
                    self.objectAnnotation.title="Couldn't find address info...";
                    return
                }
                if placemarks.count > 0
                {
                    let pm = placemarks[0] as! CLPlacemark
                    self.addressString = self.selectedLocation!.getLocationAddress(pm)
                    self.objectAnnotation.title=self.addressString
                }
                else
                {
                    self.objectAnnotation.title="Couldn't find address info.";
                    println("Problem with the data received from geocoder")
                }
                
                self.loadingAnimation.stopAnimating()

        })
    }
    
//MARK: - Pick and Cancel Button Actions -
    @IBAction func cancelButtonTouched(sender: UIButton)
    {
        self .dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectLocationButtonTouched(sender: UIButton)
    {
        if self.selectedLocation != nil
        {
            selectedLocationDelegate?.locationSelected(selectedLocation)
        }
        self .dismissViewControllerAnimated(true, completion: nil)
    }
    
//MARK: - END OF SUPERCLASS -
}
