//
//  LoginViewController.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var usernameTextField: UITextField!

    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var debugTextLabel: UILabel!

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
                } else {
                    performUIUpdatesOnMain({
                        self.activityIndicatorView.stopAnimating()
                        self.displayError(errorString)
                        self.setUIEnabled(true)
                    })
                }
            })
        }
    }
    

    @IBAction func signUpButton(sender: AnyObject) {
        let app = UIApplication.sharedApplication()
        if let toOpen: String = "https://www.udacity.com/account/auth#!/signup" {
            app.openURL(NSURL(string: toOpen)!)
        }
    }
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUIEnabled(true)
        subscribeToKeyboardNotifications()
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
            //debugTextLabel.text = errorString //****************************************************************************************************************************************
            // create the alert
            let alert = UIAlertController(title: "Login failed.", message: "\(errorString) Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            // show the alert
            self.presentViewController(alert, animated: true, completion: nil)
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
    
    //MARK: Text Field methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
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
        if usernameTextField.isFirstResponder() {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.5
        }
        if passwordTextField.isFirstResponder() {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.5
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if usernameTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
        if passwordTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    

}
