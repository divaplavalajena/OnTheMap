//
//  InfoPostViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cancelOutlet: UIButton!
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var studyLabel: UILabel!
    @IBOutlet var locationTextView: UITextView!
    
    @IBOutlet var findOnMapOutlet: UIButton!
    @IBAction func findOnMapButton(sender: AnyObject) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        // Forward Geocode the string from the locationTextView and pass to map
        if locationTextView.text == nil {
            print("no address to geocode - please enter an location")
        } else {
            forwardGeocoding(locationTextView.text)
            StudentClient.sharedInstance().userMapString = locationTextView.text
            activityIndicator.stopAnimating()
        }

        
        studyLabel.hidden = true
        locationTextView.hidden = true
        findOnMapOutlet.hidden = true
        
        view.backgroundColor = UIColor(red: 0.46666667, green: 0.71764706, blue: 0.90196078, alpha: 1.0)
        mapView.hidden = false
        linkEntryTextView.hidden = false
        linkEntryTextView.text = "Enter a Link to Share Here"
        linkEntryTextView.textColor = UIColor.whiteColor()
        submitOutlet.hidden = false
        
        cancelOutlet.hidden = false
        cancelOutlet.titleLabel!.textColor = UIColor.whiteColor()
        
    }
    
    @IBOutlet var submitOutlet: UIButton!
    @IBAction func submitButton(sender: AnyObject) {
        
        //TODO: Gather firstName, lastName, and mapURL to save in post to parse
        if linkEntryTextView.text == nil {
            print("no link entry to save for post to parse - please enter an location")
            //TODO: Insert an alert view here
        } else {
            StudentClient.sharedInstance().userMediaURL = linkEntryTextView.text
            if StudentClient.sharedInstance().userMediaURL != nil {
                StudentClient.sharedInstance().postStudentLocationToParse { (result, error) in
                    performUIUpdatesOnMain {
                        if let userInfo = result {
                            print("There were no errors posting userInfo to parse: \(userInfo)")
                        } else {
                            //TODO: create alert view that warns user info not posted to parse - try again
                            print(error)
                        }
                    }
                }
            }
        }
        activityIndicator.hidden = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var linkEntryTextView: UITextView!
    
    func textViewDidBeginEditing(textView: UITextView) {
        if locationTextView.hidden == false {
            locationTextView.becomeFirstResponder()
            if locationTextView.text == "Enter Your Location Here" {
                locationTextView.text = ""
                locationTextView.textColor = UIColor.whiteColor()
            }
        }
        
        if linkEntryTextView.hidden == false {
            linkEntryTextView.becomeFirstResponder()
            if linkEntryTextView.text == "Enter a Link to Share Here" {
                linkEntryTextView.text = ""
                linkEntryTextView.textColor = UIColor.whiteColor()
            }
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if locationTextView.text.isEmpty {
            locationTextView.text = "Enter Your Location Here"
            locationTextView.textColor = UIColor.lightGrayColor()
        }
        locationTextView.resignFirstResponder()
        
        if linkEntryTextView.text.isEmpty {
            linkEntryTextView.text = "Enter a Link to Share Here"
            linkEntryTextView.textColor = UIColor.whiteColor()
        }
        linkEntryTextView.resignFirstResponder()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        //view.backgroundColor = UIColor(red: 230.0, green: 230.0, blue: 230.0, alpha: 1.0)
        studyLabel.hidden = false
        locationTextView.hidden = false
        locationTextView.text = "Enter Your Location Here"
        locationTextView.textColor = UIColor.whiteColor()
        findOnMapOutlet.hidden = false
        cancelOutlet.hidden = false
        
        activityIndicator.hidden = true
        mapView.hidden = true
        linkEntryTextView.hidden = true
        submitOutlet.hidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    //MARK: - Forward Geocoding address 
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                
                //TODO: Place alert view here for error in forward geocoding location
                
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                
                //separate out lat and long for CLLocation use for map zoom
                let coordLat = coordinate!.latitude
                let coordLong = coordinate!.longitude
                
                //set lat and long to sharedInstance values for method that will use info
                StudentClient.sharedInstance().userLatitude = coordLat
                StudentClient.sharedInstance().userLongitude = coordLong
                
                //print for testing
                //print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")*********************************************************************************
                
                //create objects containing annotation data to add to map
                var annotations = [MKPointAnnotation]()
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate!
                annotation.title = self.locationTextView.text
                annotations.append(annotation)
                self.mapView.addAnnotations(annotations)
                
                //map zoom to location specified
                let coordinateZoom = CLLocation(latitude: coordLat, longitude: coordLong)
                self.centerMapOnLocation(coordinateZoom)
            }
        })
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    /*
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    */
    
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
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
