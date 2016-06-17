//
//  StudentInfoManager.swift
//  On The Map
//
//  Created by Jena Grafton on 6/17/16.
//  Copyright © 2016 Bella Voce Productions. All rights reserved.
//

import Foundation

class StudentInfoManager {
    
    var studentLocations: [StudentInfo] = [StudentInfo]()
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> StudentInfoManager {
        struct Singleton {
            static var sharedInstance = StudentInfoManager()
        }
        return Singleton.sharedInstance
    }
    
}