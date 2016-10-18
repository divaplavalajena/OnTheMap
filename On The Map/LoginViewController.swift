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
    @IBAction func loginButton(_ sender: AnyObject) {
        
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
    

    @IBAction func signUpButton(_ sender: AnyObject) {
        let app = UIApplication.shared
        let toOpen = URL(string: "https://www.udacity.com/account/auth#!/signup")
        app.open(toOpen!, options: [:], completionHandler: nil)
        
    }
    
    //MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUIEnabled(true)
    }
    
    //MARK: UI Login and other helper methods
    fileprivate func completeLogin() {
        activityIndicatorView.stopAnimating()
        debugTextLabel.text = ""
        //setUIEnabled(true)
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ManagerTabBarController") as! UITabBarController
        present(controller, animated: true, completion: nil)
        
    }

    fileprivate func displayError(_ errorString: String?) {
        if let errorString = errorString {
            print(errorString)
            
            if Reachability.connectedToNetwork() == false  {
                print("The internet is not reachable (displayError called on LoginVC)")
                
                // create the alert
                let alert = UIAlertController(title: "Login failed.", message: "Internet connection appears to be offline. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            } else {
                print("The internet is reachable (displayError called on LoginVC)")
                // create the alert
                let alert = UIAlertController(title: "Login failed.", message: "Incorrect username and/or password. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    fileprivate func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButtonOutlet.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButtonOutlet.alpha = 1.0
        } else {
            loginButtonOutlet.alpha = 0.5
        }
    }
    
    //MARK: Text Field methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
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
        if usernameTextField.isFirstResponder {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.5
        }
        if passwordTextField.isFirstResponder {
            self.view.frame.origin.y = getKeyboardHeight(notification) * -0.5
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if usernameTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
        if passwordTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }

    
}
