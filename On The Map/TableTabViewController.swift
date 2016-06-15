//
//  TableTabViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class TableTabViewController: UIViewController {
    
    // MARK: Properties
    
    //Listener for Reachability of Network connection
    var reachability: Reachability? = StudentClient.sharedInstance().reachability

    @IBOutlet var tableView: UITableView!
    
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
    
    @IBAction func refreshButton(sender: AnyObject) {
        loadStudentData()
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
        
        loadStudentData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func loadStudentData() {
        StudentClient.sharedInstance().getStudentLocationsSort { (result, error) in
            performUIUpdatesOnMain{
                if let students = result {
                    StudentClient.sharedInstance().studentLocations = students
                    self.tableView.reloadData()
                } else {
                    print(error)
                    
                    if self.reachability?.currentReachabilityStatus == .NotReachable {
                        print("The internet is not reachable (error called on TableTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Internet connection appears to be offline. Please reconnect and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        
                        // show the alert
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        print("The internet is reachable (error called on TableTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Student Location information failed to download.  Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                        
                        // show the alert
                        self.presentViewController(alert, animated: true, completion: nil)
                    }

                }

            }
        }
    }
    
    
    
}



extension TableTabViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "Cell"
        let student = StudentClient.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        let studentName = "\(student.firstName!) \(student.lastName!)"
        cell.textLabel!.text = studentName
        cell.detailTextLabel!.text = student.mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentClient.sharedInstance().studentLocations.count
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let student = StudentClient.sharedInstance().studentLocations[indexPath.row]
        if let toOpen = student.mediaURL {
            app.openURL(NSURL(string: toOpen)!)
        }
    }


}

