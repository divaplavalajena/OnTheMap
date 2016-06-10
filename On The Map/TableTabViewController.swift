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
    var students: [StudentInfo] = [StudentInfo]()

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
    
    
    @IBAction func refreshButton(sender: AnyObject) {
        loadStudentData()
    }
    
    override func viewWillAppear(animated: Bool) {
        loadStudentData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    func loadStudentData() {
        StudentClient.sharedInstance().getStudentLocations { (result, error) in
            performUIUpdatesOnMain{
                if let students = result {
                    self.students = students
                    self.tableView.reloadData()
                } else {
                    print(error)
                }

            }
        }
    }
    
    
    
}



extension TableTabViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "Cell"
        let student = self.students[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        /* Set cell defaults */
        let studentName = "\(student.firstName!) \(student.lastName!)"
        cell.textLabel!.text = studentName
        cell.detailTextLabel!.text = student.mediaURL
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.students.count
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let student = self.students[indexPath.row]
        if let toOpen = student.mediaURL {
            app.openURL(NSURL(string: toOpen)!)
        }
    }


}

