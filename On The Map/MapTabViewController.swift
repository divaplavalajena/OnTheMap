//
//  MapTabViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {
    
    //Listener for Reachability of Network connection
    var reachability: Reachability? = StudentClient.sharedInstance().reachability
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBAction func logoutButton(sender: AnyObject) {

        StudentClient.sharedInstance().udacityDELETESession { (success, errorString) in
            if success {
                print("Logout successful - dismissing controller")
            } else {
                print(errorString)
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func refreshButton(sender: AnyObject) {
        activityIndicator.startAnimating()
        loadStudentPins()
        activityIndicator.stopAnimating()
    }
    
    @IBAction func newLocationButton(sender: AnyObject) {
        //Check for objectID and if its not nil, then prompt alert view for overwrite/re-entry of student location
        if StudentClient.sharedInstance().userObjectID != nil {
            //alert view asking if you wish to overwrite record
                // create the alert
            let alert = UIAlertController(title: "Overwrite?", message: "User \(StudentClient.sharedInstance().userFirstName!) \(StudentClient.sharedInstance().userLastName!) has already posted a Student Location. Would you like to Overwrite the Location?", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { (action) in
                performUIUpdatesOnMain{
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InfoPostViewController") as! InfoPostViewController
            presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        do{
            try reachability?.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        loadStudentPins()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func loadStudentPins() {
        // The "students" array is an array of dictionary objects that are similar to the JSON
        // data that you can download from parse.
        StudentClient.sharedInstance().getStudentLocations { (result, error) in
            performUIUpdatesOnMain{
                if let students = result {
                    StudentInfoManager.sharedInstance().studentLocations = students
                } else {
                    print(error)
                    if self.reachability?.currentReachabilityStatus == .NotReachable {
                        print("The internet is not reachable (error called on MapTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Internet connection appears to be offline. Please reconnect and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        
                        // show the alert
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        print("The internet is reachable (error called on MapTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Student Location information failed to download.  Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        // show the alert
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                
                // We will create an MKPointAnnotation for each dictionary in "students". The
                // point annotations will be stored in this array, and then provided to the map view.
                var annotations = [MKPointAnnotation]()
                
                // The "studentLocations" array is loaded with the data from above. We are using the dictionaries
                // to create map annotations. This would be more stylish if the dictionaries were being
                // used to create custom structs. Perhaps StudentLocation structs.
                
                for student in StudentInfoManager.sharedInstance().studentLocations {
                    
                    // Notice that the float values are being used to create CLLocationDegree values.
                    // This is a version of the Double type.
                    let lat = CLLocationDegrees(student.latitude)
                    let long = CLLocationDegrees(student.longitude)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = student.firstName!
                    let last = student.lastName!
                    let mediaURL = student.mediaURL!
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    // Finally we place the annotation in an array of annotations.
                    annotations.append(annotation)
                }
                
                // When the array is complete, we add the annotations to the map.
                self.mapView.addAnnotations(annotations)
            }
        }
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
    //    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    //
    //        if control == annotationView.rightCalloutAccessoryView {
    //            let app = UIApplication.sharedApplication()
    //            app.openURL(NSURL(string: annotationView.annotation.subtitle))
    //        }
    //    }
    
}

