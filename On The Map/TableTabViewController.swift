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
    
    @IBOutlet var tableView: UITableView!
    
    @IBAction func logoutButton(_ sender: AnyObject) {
        
        StudentClient.sharedInstance().udacityDELETESession { (success, errorString) in
            if success {
                print("Logout successful - dismissing controller")
            } else {
                print(errorString)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func newLocationButton(_ sender: AnyObject) {
        //Check for objectID and if its not nil, then prompt alert view for overwrite/re-entry of student location
        if StudentClient.sharedInstance().userObjectID != nil {
            //alert view asking if you wish to overwrite record
                // create the alert
            let alert = UIAlertController(title: "Overwrite?", message: "User \(StudentClient.sharedInstance().userFirstName!) \(StudentClient.sharedInstance().userLastName!) has already posted a Student Location. Would you like to Overwrite the Location?", preferredStyle: UIAlertControllerStyle.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: { (action) in
                performUIUpdatesOnMain{ 
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "InfoPostViewController") as! InfoPostViewController
                    self.present(controller, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "InfoPostViewController") as! InfoPostViewController
            present(controller, animated: true, completion: nil)
        }

    }
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        loadStudentData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
                    StudentInfoManager.sharedInstance().studentLocations = students
                    self.tableView.reloadData()
                } else {
                    print(error)
                    
                    if Reachability.connectedToNetwork() == false {
                        print("The internet is not reachable (error called on TableTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Internet connection appears to be offline. Please reconnect and try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("The internet is reachable (error called on TableTabVC)")
                        
                        // create the alert
                        let alert = UIAlertController(title: "Download Failed", message: "Student Location information failed to download.  Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}



extension TableTabViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "Cell"
        let student = StudentInfoManager.sharedInstance().studentLocations[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        let studentName = "\(student.firstName!) \(student.lastName!)"
        cell?.textLabel!.text = studentName
        cell?.detailTextLabel!.text = student.mediaURL
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentInfoManager.sharedInstance().studentLocations.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let student = StudentInfoManager.sharedInstance().studentLocations[(indexPath as NSIndexPath).row]
        if let toOpen = URL(string: student.mediaURL!) {
            app.open(toOpen, options: [:], completionHandler: nil)
        }
        
    }


}

