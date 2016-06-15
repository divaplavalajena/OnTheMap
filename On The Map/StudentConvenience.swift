//
//  StudentConvenience.swift
//  On The Map
//
//  Created by Jena Grafton on 6/6/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import UIKit
import Foundation

// MARK: - StudentClient (Convenient Resource Methods)

extension StudentClient {
    
    // MARK: GET Convenience Methods
    
    //Used on TableTabVC to get student locations for cells - sorted in order from most recent to oldest
    func getStudentLocationsSort(completionHandlerForStudentLocationsSort: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.ParseLimit100: "100", StudentClient.ParameterKeys.ParseOrder: "-\(StudentClient.JSONResponseKeys.UpdatedAt)"]
        let myMethod: String = StudentClient.Constants.ParseMethod
        
        /* 2. Make the request */
        taskForGETMethod(myMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocationsSort(result: nil, error: error)
            } else {
                if let results = results[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    let students = StudentInfo.studentsFromResults(results)
                    completionHandlerForStudentLocationsSort(result: students, error: nil)
                } else {
                    completionHandlerForStudentLocationsSort(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    
    //Used on MapTabVC to get student locations for pins
    func getStudentLocations(completionHandlerForStudentLocations: (result: [StudentInfo]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.ParseLimit100: "100"]
        let myMethod: String = StudentClient.Constants.ParseMethod
        
        /* 2. Make the request */
        taskForGETMethod(myMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocations(result: nil, error: error)
            } else {
                if let results = results[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    let students = StudentInfo.studentsFromResults(results)
                    for result in results {
                        if let mainUserID = result[StudentClient.JSONResponseKeys.UniqueKey] as? String where mainUserID == StudentClient.sharedInstance().userID {
                            guard let firstName = result[StudentClient.JSONResponseKeys.FirstName] as? String else {
                                print("Cannot find key 'firstName' in \(results)")
                                return
                            }
                            guard let lastName = result[StudentClient.JSONResponseKeys.LastName] as? String else {
                                print("Cannot find key 'lastName' in \(results)")
                                return
                            }
                            guard let objectID = result[StudentClient.JSONResponseKeys.ObjectID] as? String else {
                                print("Cannot find key 'objectID' in \(results)")
                                return
                            }
                            self.userFirstName = firstName
                            self.userLastName = lastName
                            self.userObjectID = objectID
                            //print("The main user info is: \(self.userFirstName!) \(self.userLastName!) with an objectID of \(self.userObjectID!)")*********************************************
                        }
                    }
                    completionHandlerForStudentLocations(result: students, error: nil)
                } else {
                    completionHandlerForStudentLocations(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    //Get udacity public user data like first and last name from userID (obtained from udacityPOSTSession)
            //Then use this user data in postStudentLocationToParse method
    func getUdacityPublicUserData(completionHandlerForGetPublicUserData: (result: [String:AnyObject]?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let mutableMethod: String = "\(Constants.GetPublicUserData)\(StudentClient.sharedInstance().userID!)"
        //print(mutableMethod)***********************************************************************************************************************************************************
        
        /* 2. Make the request */
        taskForGETUdacity(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetPublicUserData(result: nil, error: error)
            } else {
                if let userInfo = results[StudentClient.JSONResponseKeys.User] as? [String:AnyObject] {
                    if let firstName = userInfo[StudentClient.JSONResponseKeys.UserFirstName] as? String,
                        let lastName = userInfo[StudentClient.JSONResponseKeys.UserLastName] as? String {
                        self.userFirstName = firstName
                        self.userLastName = lastName
                        //print("User Name is \(self.userFirstName!) \(self.userLastName!)")*************************************************************************************************
                        //print("getUdacityPublicUserData is working in its new location")*************************************************************************************************
                    }
                    completionHandlerForGetPublicUserData(result: userInfo, error: nil)
                    
                } else {
                    completionHandlerForGetPublicUserData(result: nil, error: NSError(domain: "getUdacityPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUdacityPublicUserData"]))
                }
            }
        }
    }

    // MARK: PUT Convenience Methods
    
    //PUT or update a student location
    func updateStudentLocationToParse(completionHandlerForUPDATEStudentLocation: (result: String?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = "\(StudentClient.Constants.ParseMethod)/\(StudentClient.sharedInstance().userObjectID)"
        let jsonBody = "{\"uniqueKey\": \"\(StudentClient.sharedInstance().userID!)\", \"firstName\": \"\(StudentClient.sharedInstance().userFirstName!)\", \"lastName\": \"\(StudentClient.sharedInstance().userLastName!)\",\"mapString\": \"\(StudentClient.sharedInstance().userMapString!)\", \"mediaURL\": \"\(StudentClient.sharedInstance().userMediaURL!)\",\"latitude\": \(StudentClient.sharedInstance().userLatitude!), \"longitude\": \(StudentClient.sharedInstance().userLongitude!)}"
        print("This is new updateStudentLocationToParse jsonBody:     ")
        print(jsonBody)
        
        
        /* 2. Make the request */
        taskForUPDATEParseMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForUPDATEStudentLocation(result: nil, error: error)
            } else {
                if let updatedAt = results[StudentClient.JSONResponseKeys.UpdatedAt] as? String {
                    completionHandlerForUPDATEStudentLocation(result: updatedAt, error: nil)
                    print("The result of the updateStudentLocationToParse is updatedAt: \(updatedAt)")
                } else {
                    completionHandlerForUPDATEStudentLocation(result: nil, error: NSError(domain: "updateStudentLocationToParse parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocationToParse"]))
                }
            }
        }
    }

    
    
    // MARK: POST Convenience Methods
    
    //POST a student location to Parse
    func postStudentLocationToParse(completionHandlerForPOSTStudentLocation: (result: String?, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.ParseMethod
        let jsonBody = "{\"uniqueKey\": \"\(StudentClient.sharedInstance().userID!)\", \"firstName\": \"\(StudentClient.sharedInstance().userFirstName!)\", \"lastName\": \"\(StudentClient.sharedInstance().userLastName!)\",\"mapString\": \"\(StudentClient.sharedInstance().userMapString!)\", \"mediaURL\": \"\(StudentClient.sharedInstance().userMediaURL!)\",\"latitude\": \(StudentClient.sharedInstance().userLatitude!), \"longitude\": \(StudentClient.sharedInstance().userLongitude!)}"
        
        /* 2. Make the request */
        taskForPOSTParseMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForPOSTStudentLocation(result: nil, error: error)
            } else {
                if let objectID = results[StudentClient.JSONResponseKeys.ObjectID] as? String {
                    completionHandlerForPOSTStudentLocation(result: objectID, error: nil)
                    //print("The result of the postStudentLocationToParse is objectID: \(objectID)")*************************************************************************************************
                    self.userObjectID = objectID
                } else {
                    completionHandlerForPOSTStudentLocation(result: nil, error: NSError(domain: "postStudentLocationToParse parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocationToParse"]))
                }
            }
        }
    }

    
    
    //Get a session ID and userID and authenticate with Udacity
    func udacityPOSTSession(username: String, password: String, completionHandlerForSession: (success: Bool, sessionID: String?, userID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        /* 2. Make the request */
        taskForPOSTUdacityMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if var error = error?.localizedDescription {
                print(error)
                if error != "Incorrect username and/or password" {
                    error = "The Internet connection appears to be offline"
                }
                completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "\(error).")
            } else {
                if let sessionCategory = results[StudentClient.JSONResponseKeys.SessionCategory] as? [String: AnyObject] {
                    if let sessionID = sessionCategory[StudentClient.JSONResponseKeys.SessionID] as? String,
                        let userAccount = results[StudentClient.JSONResponseKeys.UserAccount] as? [String: AnyObject] {
                        if let userAccountID = userAccount[StudentClient.JSONResponseKeys.UserAccountID] as? String {
                            self.userID = userAccountID
                            //print("user account ID is \(self.userID!)")*************************************************************************************************
                            //print("sessionID is \(sessionID)")*************************************************************************************************
                            completionHandlerForSession(success: true, sessionID: sessionID, userID: userAccountID, errorString: nil)
                        }
                    }
                } else {
                    print("Could not find \(StudentClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, userID: nil, errorString: "Login Failed (Session ID, UserID).")
                }
            }
        }
    }
    
    // MARK: DELETE Convenience Methods

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
                //print("Logout successful")*************************************************************************************************
            }
        }
    }

    
}