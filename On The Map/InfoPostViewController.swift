//
//  InfoPostViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import MapKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class InfoPostViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var cancelOutlet: UIButton!
    @IBAction func cancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var studyLabel: UILabel!
    @IBOutlet var locationTextView: UITextView!
    
    @IBOutlet var findOnMapOutlet: UIButton!
    @IBAction func findOnMapButton(_ sender: AnyObject) {
        
        // Forward Geocode the string from the locationTextView and pass to map
        if locationTextView.text == nil || locationTextView.text == "Enter Your Location Here" || locationTextView.text == "" {
            print("no address to geocode - please enter an location") //*******************************************************************************************************
            
            // create the alert
            let alert = UIAlertController(title: "No location detected.", message: "Please enter a location or address to continue submission.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
            //forward geocoding alert view if geocoding fails - within forwardGeocoding function closure but on a main thread since alert is a UI update
            forwardGeocoding(locationTextView.text)
            StudentClient.sharedInstance().userMapString = locationTextView.text
            activityIndicator.stopAnimating()
            
            studyLabel.isHidden = true
            locationTextView.isHidden = true
            findOnMapOutlet.isHidden = true
            
            view.backgroundColor = UIColor(red: 0.46666667, green: 0.71764706, blue: 0.90196078, alpha: 1.0)
            mapView.isHidden = false
            linkEntryTextView.isHidden = false
            linkEntryTextView.text = "Enter a Link to Share Here"
            linkEntryTextView.textColor = UIColor.white
            submitOutlet.isHidden = false
            
            cancelOutlet.isHidden = false
            cancelOutlet.titleLabel!.textColor = UIColor.white
        }

    }
    
    @IBOutlet var submitOutlet: UIButton!
    @IBAction func submitButton(_ sender: AnyObject) {
        
        if linkEntryTextView.text == nil || linkEntryTextView.text == "Enter a Link to Share Here" || linkEntryTextView.text == "" {
            //print("no link entry to save for post to parse - please enter an location")****************************************************************************************************
            
            // create the alert
            let alert = UIAlertController(title: "No link URL detected.", message: "Please enter a link to continue submission.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                performUIUpdatesOnMain{
                    self.activityIndicator.stopAnimating()
                    self.studyLabel.isHidden = true
                    self.locationTextView.isHidden = true
                    self.findOnMapOutlet.isHidden = true
                    
                    self.view.backgroundColor = UIColor(red: 0.46666667, green: 0.71764706, blue: 0.90196078, alpha: 1.0)
                    self.mapView.isHidden = false
                    self.linkEntryTextView.isHidden = false
                    self.linkEntryTextView.becomeFirstResponder()
                    self.linkEntryTextView.text = ""
                    self.linkEntryTextView.textColor = UIColor.white
                    self.submitOutlet.isHidden = false
                    
                    self.cancelOutlet.isHidden = false
                    self.cancelOutlet.titleLabel!.textColor = UIColor.white
                }
            }))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            StudentClient.sharedInstance().userMediaURL = linkEntryTextView.text
            if StudentClient.sharedInstance().userMediaURL != nil {
                StudentClient.sharedInstance().postStudentLocationToParse { (result, error) in
                    performUIUpdatesOnMain {
                        if let userInfo = result {
                            print("There were no errors posting userInfo to parse: \(userInfo)")
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            print(error)
                            
                            if Reachability.connectedToNetwork() == false {
                                print("The internet is not reachable (error called on InfoPostVC)")
                                
                                // create the alert
                                let alert = UIAlertController(title: "Download Failed", message: "Internet connection appears to be offline. Please reconnect and try again.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                // create the alert
                                let alert = UIAlertController(title: "Data submission failed", message: "Student Location data failed to update. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                                
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBOutlet var linkEntryTextView: UITextView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        
        studyLabel.isHidden = false
        locationTextView.isHidden = false
        locationTextView.text = "Enter Your Location Here"
        locationTextView.textColor = UIColor.white
        findOnMapOutlet.isHidden = false
        cancelOutlet.isHidden = false
        
        activityIndicator.isHidden = true
        mapView.isHidden = true
        linkEntryTextView.isHidden = true
        submitOutlet.isHidden = true
        
        if Reachability.connectedToNetwork() == true {
            print("Internet Connection Available!")
        } else {
            print("Internet Connection NOT Available!")
            let alert = UIAlertController(title: "Internet Connection not available!", message: "Please connect and try again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationTextView.delegate = self
        linkEntryTextView.delegate = self
    }
    
    //MARK: - Forward Geocoding address 
    
    func forwardGeocoding(_ address: String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error)
                performUIUpdatesOnMain{
                    if Reachability.connectedToNetwork() == false {
                        print("The internet is not reachable (error called on InfoPostVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Location Geocoding Failed", message: "Internet connection appears to be offline. Please reconnect and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                            performUIUpdatesOnMain{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        // create the alert
                        let alert = UIAlertController(title: "Location Geocoding Failed", message: "Location or address failed to properly forward geocode. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                            performUIUpdatesOnMain{
                                self.dismiss(animated: true, completion: nil)
                            }
                        }))
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
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
    
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //MARK: Text Field methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        if locationTextView.isHidden == false {
            locationTextView.becomeFirstResponder()
            if locationTextView.text == "Enter Your Location Here" {
                locationTextView.text = ""
                locationTextView.textColor = UIColor.white
            }
        }
        
        if linkEntryTextView.isHidden == false {
            linkEntryTextView.becomeFirstResponder()
            if linkEntryTextView.text == "Enter a Link to Share Here" {
                linkEntryTextView.text = ""
                linkEntryTextView.textColor = UIColor.white
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if locationTextView.text.isEmpty {
            locationTextView.text = "Enter Your Location Here"
            locationTextView.textColor = UIColor.lightGray
        }
        locationTextView.resignFirstResponder()
        
        if linkEntryTextView.text.isEmpty {
            linkEntryTextView.text = "Enter a Link to Share Here"
            linkEntryTextView.textColor = UIColor.white
        }
        linkEntryTextView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    //MARK: Keyboard methods
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if locationTextView.isFirstResponder {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.5
        }
        if linkEntryTextView.isFirstResponder {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.2
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if locationTextView.isFirstResponder {
            self.view.frame.origin.y = 0
        }
        if linkEntryTextView.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    

}
