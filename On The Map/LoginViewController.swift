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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        debugTextLabel.text = ""
    }

    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    @IBOutlet var loginButtonOutlet: UIButton!
    @IBAction func loginButton(sender: AnyObject) {
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            activityIndicatorView.startAnimating()
            
            udacityPOSTSession(usernameTextField.text!, password: passwordTextField.text!, completionHandlerForSession: { (success, sessionID, errorString) in
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

        
        /*
         TMDBClient.sharedInstance().authenticateWithViewController(self) { (success, errorString) in
         performUIUpdatesOnMain {
         if success {
         self.completeLogin()
         } else {
         self.displayError(errorString)
         }
         }
         }
         */
    }
    

    @IBAction func signUpButton(sender: AnyObject) {
    }
    
    
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
    
    //Get a session ID to authenticate with Udacity
    func udacityPOSTSession(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        /* 2. Make the request */
        taskForPOSTMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionCategory = results[StudentClient.JSONResponseKeys.SessionCategory] as? [NSDictionary] {
                    if let sessionID = sessionCategory[StudentClient.JSONResponseKeys.SessionID] as? String {
                        completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                        print("sessionID is \(sessionID)")
                    }
                } else {
                    print("Could not find \(StudentClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }

        
    }

    
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        var parameters = parameters
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: udacityURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // create a URL from parameters
    private func udacityURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = StudentClient.Constants.ApiScheme
        components.host = StudentClient.Constants.ApiHost
        components.path = StudentClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }

    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(result: parsedResult, error: nil)
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
