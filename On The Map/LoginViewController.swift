//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var debugTextLabel: UILabel!
    
    // shared session
    var session = NSURLSession.sharedSession()

    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet var loginButtonOutlet: UIButton!
    @IBAction func loginButton(sender: AnyObject) {
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            activityIndicatorView.startAnimating()
            
            //Create a session on udacity - LOGIN
            StudentClient.sharedInstance().udacityPOSTSession(usernameTextField.text!, password: passwordTextField.text!, completionHandlerForSession: { (success, sessionID, userID, errorString) in
                if success {
                    
                    //Get Udacity public user data from userID in previous method that you'll use later - firstName, lastName, etc.
                    StudentClient.sharedInstance().getUdacityPublicUserData({ (result, error) in
                        
                        //All UI updates need to be on main thread since all closures run on background threads - so thread must be specified here.
                        performUIUpdatesOnMain {
                            if success {
                                self.completeLogin()
                            } else {
                                self.activityIndicatorView.stopAnimating()
                                self.displayError(errorString)
                                self.setUIEnabled(true)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    

    @IBAction func signUpButton(sender: AnyObject) {
    }
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIEnabled(true)
    }
    
    //MARK: UI Login and other helper methods
    private func completeLogin() {
        activityIndicatorView.stopAnimating()
        debugTextLabel.text = ""
        //setUIEnabled(true)
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ManagerTabBarController") as! UITabBarController
        presentViewController(controller, animated: true, completion: nil)
        
    }

    private func displayError(errorString: String?) {
        if let errorString = errorString {
            debugTextLabel.text = errorString
        }
    }

    private func setUIEnabled(enabled: Bool) {
        usernameTextField.enabled = enabled
        passwordTextField.enabled = enabled
        loginButtonOutlet.enabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButtonOutlet.alpha = 1.0
        } else {
            loginButtonOutlet.alpha = 0.5
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
