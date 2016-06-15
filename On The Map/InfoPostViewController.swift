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
        
        // Forward Geocode the string from the locationTextView and pass to map
        if locationTextView.text == nil || locationTextView.text == "Enter Your Location Here" || locationTextView.text == "" {
            print("no address to geocode - please enter an location") //*******************************************************************************************************
            
            // create the alert
            let alert = UIAlertController(title: "No location detected.", message: "Please enter a location or address to continue submission.", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            //forward geocoding alert view if geocoding fails - within forwardGeocoding function closure but on a main thread since alert is a UI update
            forwardGeocoding(locationTextView.text)
            StudentClient.sharedInstance().userMapString = locationTextView.text
            activityIndicator.stopAnimating()
            
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

    }
    
    @IBOutlet var submitOutlet: UIButton!
    @IBAction func submitButton(sender: AnyObject) {
        
        if linkEntryTextView.text == nil || linkEntryTextView.text == "Enter a Link to Share Here" || linkEntryTextView.text == "" {
            //print("no link entry to save for post to parse - please enter an location")****************************************************************************************************
            
            // create the alert
            let alert = UIAlertController(title: "No link URL detected.", message: "Please enter a link to continue submission.", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                performUIUpdatesOnMain{
                    self.activityIndicator.stopAnimating()
                    self.studyLabel.hidden = true
                    self.locationTextView.hidden = true
                    self.findOnMapOutlet.hidden = true
                    
                    self.view.backgroundColor = UIColor(red: 0.46666667, green: 0.71764706, blue: 0.90196078, alpha: 1.0)
                    self.mapView.hidden = false
                    self.linkEntryTextView.hidden = false
                    self.linkEntryTextView.becomeFirstResponder()
                    self.linkEntryTextView.text = ""
                    self.linkEntryTextView.textColor = UIColor.whiteColor()
                    self.submitOutlet.hidden = false
                    
                    self.cancelOutlet.hidden = false
                    self.cancelOutlet.titleLabel!.textColor = UIColor.whiteColor()
                }
            }))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            StudentClient.sharedInstance().userMediaURL = linkEntryTextView.text
            if StudentClient.sharedInstance().userMediaURL != nil {
                StudentClient.sharedInstance().postStudentLocationToParse { (result, error) in
                    performUIUpdatesOnMain {
                        if let userInfo = result {
                            print("There were no errors posting userInfo to parse: \(userInfo)")
                        } else {
                            print(error)
                            
                            // create the alert
                            let alert = UIAlertController(title: "Data submission failed", message: "Student Location data failed to update. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            
                            // add an action (button)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            
                            // show the alert
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            performUIUpdatesOnMain{
                self.activityIndicator.hidden = true
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBOutlet var linkEntryTextView: UITextView!
    
    
    override func viewWillAppear(animated: Bool) {
        subscribeToKeyboardNotifications()
        
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
        
        locationTextView.delegate = self
        linkEntryTextView.delegate = self
    }
    
    //MARK: - Forward Geocoding address 
    
    func forwardGeocoding(address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                performUIUpdatesOnMain{
                    // create the alert
                    let alert = UIAlertController(title: "Location geocoding failed.", message: "Location or address failed to properly forward geocode. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))

                    // show the alert
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
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
    
    //MARK: Text Field methods
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
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    //MARK: Keyboard methods
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if locationTextView.isFirstResponder() {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
        if linkEntryTextView.isFirstResponder() {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if locationTextView.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        if linkEntryTextView.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    

}
