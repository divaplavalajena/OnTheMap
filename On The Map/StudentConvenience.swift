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
    func getStudentLocationsSort(_ completionHandlerForStudentLocationsSort: @escaping (_ result: [StudentInfo]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.ParseLimit100: "100", StudentClient.ParameterKeys.ParseOrder: "-\(StudentClient.JSONResponseKeys.UpdatedAt)"]
        let myMethod: String = StudentClient.Constants.ParseMethod
        
        /* 2. Make the request */
        let _ = taskForGETMethod(myMethod, parameters: parameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocationsSort(nil, error)
            } else {
                if let results = results?[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    let students = StudentInfo.studentsFromResults(results)
                    completionHandlerForStudentLocationsSort(students, nil)
                } else {
                    completionHandlerForStudentLocationsSort(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    
    //Used on MapTabVC to get student locations for pins
    func getStudentLocations(_ completionHandlerForStudentLocations: @escaping (_ result: [StudentInfo]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.ParseLimit100: "100"]
        let myMethod: String = StudentClient.Constants.ParseMethod
        
        /* 2. Make the request */
        let _ = taskForGETMethod(myMethod, parameters: parameters as [String : AnyObject]) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForStudentLocations(nil, error)
            } else {
                if let results = results?[StudentClient.JSONResponseKeys.StudentResults] as? [[String:AnyObject]] {
                    let students = StudentInfo.studentsFromResults(results)
                    for result in results {
                        if let mainUserID = result[StudentClient.JSONResponseKeys.UniqueKey] as? String , mainUserID == StudentClient.sharedInstance().userID {
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
                            //print("The main user info is: \(self.userFirstName!) \(self.userLastName!) with an objectID of \(self.userObjectID!)")
                        }
                    }
                    completionHandlerForStudentLocations(students, nil)
                } else {
                    completionHandlerForStudentLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }

    //Get udacity public user data like first and last name from userID (obtained from udacityPOSTSession)
            //Then use this user data in postStudentLocationToParse method
    func getUdacityPublicUserData(_ completionHandlerForGetPublicUserData: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let mutableMethod: String = "\(Constants.GetPublicUserData)\(StudentClient.sharedInstance().userID!)"
        //print(mutableMethod)
        
        /* 2. Make the request */
        let _ = taskForGETUdacity(mutableMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForGetPublicUserData(nil, error)
            } else {
                if let userInfo = results?[StudentClient.JSONResponseKeys.User] as? [String:AnyObject] {
                    if let firstName = userInfo[StudentClient.JSONResponseKeys.UserFirstName] as? String,
                        let lastName = userInfo[StudentClient.JSONResponseKeys.UserLastName] as? String {
                        self.userFirstName = firstName
                        self.userLastName = lastName
                        //print("User Name is \(self.userFirstName!) \(self.userLastName!)")
                        //print("getUdacityPublicUserData is working in its new location")
                    }
                    completionHandlerForGetPublicUserData(userInfo, nil)
                    
                } else {
                    completionHandlerForGetPublicUserData(nil, NSError(domain: "getUdacityPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getUdacityPublicUserData"]))
                }
            }
        }
    }

    // MARK: PUT Convenience Methods
    
    //PUT or update a student location
    func updateStudentLocationToParse(_ completionHandlerForUPDATEStudentLocation: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = "\(StudentClient.Constants.ParseMethod)/\(StudentClient.sharedInstance().userObjectID)"
        let jsonBody = "{\"uniqueKey\": \"\(StudentClient.sharedInstance().userID!)\", \"firstName\": \"\(StudentClient.sharedInstance().userFirstName!)\", \"lastName\": \"\(StudentClient.sharedInstance().userLastName!)\",\"mapString\": \"\(StudentClient.sharedInstance().userMapString!)\", \"mediaURL\": \"\(StudentClient.sharedInstance().userMediaURL!)\",\"latitude\": \(StudentClient.sharedInstance().userLatitude!), \"longitude\": \(StudentClient.sharedInstance().userLongitude!)}"
        //print("This is new updateStudentLocationToParse jsonBody: ")
        //print(jsonBody)
        
        
        /* 2. Make the request */
        let _ = taskForUPDATEParseMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForUPDATEStudentLocation(nil, error)
            } else {
                if let updatedAt = results?[StudentClient.JSONResponseKeys.UpdatedAt] as? String {
                    completionHandlerForUPDATEStudentLocation(updatedAt, nil)
                    print("The result of the updateStudentLocationToParse is updatedAt: \(updatedAt)")
                } else {
                    completionHandlerForUPDATEStudentLocation(nil, NSError(domain: "updateStudentLocationToParse parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocationToParse"]))
                }
            }
        }
    }

    
    
    // MARK: POST Convenience Methods
    
    //POST a student location to Parse
    func postStudentLocationToParse(_ completionHandlerForPOSTStudentLocation: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.ParseMethod
        let jsonBody = "{\"uniqueKey\": \"\(StudentClient.sharedInstance().userID!)\", \"firstName\": \"\(StudentClient.sharedInstance().userFirstName!)\", \"lastName\": \"\(StudentClient.sharedInstance().userLastName!)\",\"mapString\": \"\(StudentClient.sharedInstance().userMapString!)\", \"mediaURL\": \"\(StudentClient.sharedInstance().userMediaURL!)\",\"latitude\": \(StudentClient.sharedInstance().userLatitude!), \"longitude\": \(StudentClient.sharedInstance().userLongitude!)}"
        
        /* 2. Make the request */
        let _ = taskForPOSTParseMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForPOSTStudentLocation(nil, error)
            } else {
                if let objectID = results?[StudentClient.JSONResponseKeys.ObjectID] as? String {
                    completionHandlerForPOSTStudentLocation(objectID, nil)
                    //print("The result of the postStudentLocationToParse is objectID: \(objectID)")
                    self.userObjectID = objectID
                } else {
                    completionHandlerForPOSTStudentLocation(nil, NSError(domain: "postStudentLocationToParse parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocationToParse"]))
                }
            }
        }
    }

    
    
    //Get a session ID and userID and authenticate with Udacity
    func udacityPOSTSession(_ username: String, password: String, completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ userID: String?, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        let jsonBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        /* 2. Make the request */
        let _ = taskForPOSTUdacityMethod(myMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if var error = error?.localizedDescription {
                print(error)
                if error != "Incorrect username and/or password" {
                    error = "The Internet connection appears to be offline"
                }
                completionHandlerForSession(false, nil, nil, "\(error).")
            } else {
                if let results = results {
                    if let sessionCategory = results[StudentClient.JSONResponseKeys.SessionCategory] as? [String: AnyObject] {
                        if let sessionID = sessionCategory[StudentClient.JSONResponseKeys.SessionID] as? String,
                            let userAccount = results[StudentClient.JSONResponseKeys.UserAccount] as? [String: AnyObject] {
                            if let userAccountID = userAccount[StudentClient.JSONResponseKeys.UserAccountID] as? String {
                                self.userID = userAccountID
                                //print("user account ID is \(self.userID!)")
                                //print("sessionID is \(sessionID)")
                                completionHandlerForSession(true, sessionID, userAccountID, nil)
                            }
                        }
                    } else {
                        print("Could not find \(StudentClient.JSONResponseKeys.SessionID) in \(results)")
                        completionHandlerForSession(false, nil, nil, "Login Failed (Session ID, UserID).")
                    }
                }
            }
        }
    }
    
    // MARK: DELETE Convenience Methods

    func udacityDELETESession(_ completionHandlerForDeleteSession: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [String:AnyObject]()
        let myMethod: String = StudentClient.Constants.SessionAuthentication
        
        
        /* 2. Make the request */
        let _ = taskForDELETEUdacityMethod(myMethod, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForDeleteSession(false, "Logout Failed.")
            } else {
                completionHandlerForDeleteSession(true, nil)
                //print("Logout successful")
            }
        }
    }

    
}
