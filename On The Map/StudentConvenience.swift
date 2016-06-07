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
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        self.getSessionID(requestToken) { (success, sessionID, errorString) in
            if success {
                // success! we have the sessionID!
                self.sessionID = sessionID
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    private func getSessionID(requestToken: String?, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.RequestToken: requestToken!]
        
        /* 2. Make the request */
        taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionID = results[StudentClient.JSONResponseKeys.SessionID] as? String {
                    completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                } else {
                    print("Could not find \(StudentClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    // MARK: POST Convenience Methods
    
    func postToFavorites(movie: StudentInfo, favorite: Bool, completionHandlerForFavorite: (result: Int?, error: NSError?) -> Void)  {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let parameters = [StudentClient.ParameterKeys.SessionID : StudentClient.sharedInstance().sessionID!]
        var mutableMethod: String = Methods.AccountIDFavorite
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: StudentClient.URLKeys.UserID, value: String(StudentClient.sharedInstance().userID!))!
        let jsonBody = "{\"\(StudentClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(StudentClient.JSONBodyKeys.MediaID)\": \"\(StudentClient.JSONResponseKeys.lastName)\",\"\(StudentClient.JSONBodyKeys.Favorite)\": \(favorite)}"
        
        /* 2. Make the request */
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForFavorite(result: nil, error: error)
            } else {
                if let results = results[StudentClient.JSONResponseKeys.StatusCode] as? Int {
                    completionHandlerForFavorite(result: results, error: nil)
                } else {
                    completionHandlerForFavorite(result: nil, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                }
            }
        }
    }



    
}