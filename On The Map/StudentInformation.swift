//
//  StudentInformation.swift
//  On The Map
//
//  Created by Jena Grafton on 6/1/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//


// MARK: - TMDBMovie

struct StudentInfo {
    
    // MARK: Properties
    
    let firstName: String
    let lastName: String
    let linkURL: String?
    let latitude: String?
    let longitude: String?
    
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        firstName = dictionary[StudentClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[StudentClient.JSONResponseKeys.lastName] as! String
        latitude = dictionary[StudentClient.JSONResponseKeys.latitude] as? String
        longitude = dictionary[StudentClient.JSONResponseKeys.longitude] as? String
        linkURL = dictionary[StudentClient.JSONResponseKeys.linkURL] as? String
        
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