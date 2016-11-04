//
//  StudentInformation.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation

// MARK: - StudentInfo

struct StudentInfo {
    
    // MARK: Properties
    let objectID: String?
    
    let uniqueKey: String?
    
    let firstName: String?
    let lastName: String?
    
    let mapString: String?
    let mediaURL: String?
    
    let latitude: Double?
    let longitude: Double?
    
    let createdAt: Date?
    let updatedAt: Date?
    
    
    
    // MARK: Initializers
    
    // construct a StudentInfo from a dictionary
    init(dictionary: [String:AnyObject]) {
        objectID = dictionary[StudentClient.JSONResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[StudentClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[StudentClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[StudentClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[StudentClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[StudentClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[StudentClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[StudentClient.JSONResponseKeys.Longitude] as? Double
        createdAt = dictionary[StudentClient.JSONResponseKeys.CreatedAt] as? Date
        updatedAt = dictionary[StudentClient.JSONResponseKeys.UpdatedAt] as? Date
    }
    
    static func studentsFromResults(_ results: [[String:AnyObject]]) -> [StudentInfo] {
        
        var students = [StudentInfo]()
        
        // iterate through results array of dictionaries, each result is a dictionary
        for result in results {
            students.append(StudentInfo(dictionary: result))
        }
        
        return students
    }
    
}


// MARK: - StudentInfo: Equatable

extension StudentInfo: Equatable {}

func ==(lhs: StudentInfo, rhs: StudentInfo) -> Bool {
    return lhs.uniqueKey == rhs.uniqueKey
}


