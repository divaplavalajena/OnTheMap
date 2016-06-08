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
    
    let firstName: String
    let lastName: String
    
    let mapString: String?
    let mediaURL: String?
    
    let latitude: Double?
    let longitude: Double?
    
    let createdAt: NSDate?
    let updatedAt: NSDate?
    
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[StudentClient.JSONResponseKeys.FirstName] as! String
        lastName = dictionary[StudentClient.JSONResponseKeys.LastName] as! String
        mapString = dictionary[StudentClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[StudentClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[StudentClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[StudentClient.JSONResponseKeys.Longitude] as? Double
        createdAt = dictionary[StudentClient.JSONResponseKeys.CreatedAt] as? NSDate
        updatedAt = dictionary[StudentClient.JSONResponseKeys.UpdatedAt] as? NSDate
    }
    
    static func studentsFromResults(results: [[String:AnyObject]]) -> [StudentInfo] {
        
        var students = [StudentInfo]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for student in students {
            students.append(student)
        }
        
        return students
    }
}

/*
// MARK: - TMDBMovie: Equatable

extension StudentInfo: Equatable {}

func ==(lhs: StudentInfo, rhs: StudentInfo) -> Bool {
    return lhs.lastName == rhs.lastName
}
*/