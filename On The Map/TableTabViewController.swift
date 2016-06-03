//
//  TableTabViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class TableTabViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        //TODO: Log Out of Udacity
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func refreshButton(sender: AnyObject) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

