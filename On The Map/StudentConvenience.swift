//
//  StudentConvenience.swift
//  On The Map
//
//  Created by Jena Grafton on 6/6/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension StudentClient {
    
    // MARK: GET Convenience Methods
    
    func getStudentLocations(completionHandlerForStudentLocations: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        //let parameters = [String:AnyObject]() /***** placeholder real one one line below needs work *******/
        let parameters = [StudentClient.ParameterKeys.ParseLimit100: "100"]
        let myMethod: String = StudentClient.Constants.ParseMethod
        
        /* 2. Make the request */
        taskForGETMethod(myMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocations(result: nil, error: error)
            } else {
                if let results = results[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    print("The number of students in results from JSON is: \(results.count)")
                    print("results array of dictionaries taskForGetMethod after parsing JSON \(results)")
                    let students = StudentInfo.studentsFromResults(results)
                    completionHandlerForStudentLocations(result: students, error: nil)
                    //print("students array of dictionaries after studentsFromResults function call: \(students)")
                } else {
                    completionHandlerForStudentLocations(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    
    func getUdacityPublicUserData(completionHandlerForGetPublicUserData: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        var mutableMethod: String = Constants.GetPublicUserData
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: StudentClient.URLKeys.UserID, value: String(StudentClient.sharedInstance().userID!))!
        
        /* 2. Make the request */
        taskForGETUdacity(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetPublicUserData(result: nil, error: error)
            } else {
                if let results = results[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    let students = StudentInfo.studentsFromResults(results)
                    completionHandlerForGetPublicUserData(result: students, error: nil)
                } else {
                    completionHandlerForGetPublicUserData(result: nil, error: NSError(domain: "getUdacityPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUdacityPublicUserData"]))
                }
            }
        }
    }

    
    
    // MARK: POST Convenience Methods
    
    //Get a session ID and userID and authenticate with Udacity
    func udacityPOSTSession(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        /* 2. Make the request */
        taskForPOSTUdacityMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionCategory = results[StudentClient.JSONResponseKeys.SessionCategory] as? [String: AnyObject] {
                    if let sessionID = sessionCategory[StudentClient.JSONResponseKeys.SessionID] as? String {
                        completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                        print("sessionID is \(sessionID)")
                    }
                    if let userAccount = results[StudentClient.JSONResponseKeys.UserAccount] as? [String: AnyObject] {
                        if let userAccountID = userAccount[StudentClient.JSONResponseKeys.UserAccountID] as? String {
                            self.userID = userAccountID
                            print("user account ID is \(self.userID!)")
                        }
                    }
                } else {
                    print("Could not find \(StudentClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }

    func udacityDELETESession(completionHandlerForDeleteSession: (success: Bool, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        
        
        /* 2. Make the request */
        taskForDELETEUdacityMethod(myMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForDeleteSession(success: false, errorString: "Logout Failed.")
            } else {
                completionHandlerForDeleteSession(success: true, errorString: nil)
                print("Logout successful")
            }
        }
    }

    
}