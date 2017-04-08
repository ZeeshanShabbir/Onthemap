//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/5/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
struct StudentInfo {
    let objectId : String?
    let firstName: String?
    let lastName : String?
    let latitude : Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL : String?
    let uniqueKey: String?
    let updatedAt: String?
    let createdAt: String?

    
    init(dict:[String:AnyObject]){
        objectId  = dict[APIClient.JSONResponseKeys.objectID]   != nil ? dict[APIClient.JSONResponseKeys.objectID]  as? String : ""
        firstName = dict[APIClient.JSONResponseKeys.firstName]  != nil ? dict[APIClient.JSONResponseKeys.firstName] as? String : ""
        lastName  = dict[APIClient.JSONResponseKeys.lastName]   != nil ? dict[APIClient.JSONResponseKeys.lastName]  as? String : ""
        latitude  = dict[APIClient.JSONResponseKeys.latitude]   != nil ? dict[APIClient.JSONResponseKeys.latitude]  as? Double : 0
        longitude = dict[APIClient.JSONResponseKeys.longitude]  != nil ? dict[APIClient.JSONResponseKeys.longitude] as? Double : 0
        mapString = dict[APIClient.JSONResponseKeys.mapString]  != nil ? dict[APIClient.JSONResponseKeys.mapString] as? String : ""
        mediaURL  = dict[APIClient.JSONResponseKeys.mediaURL]   != nil ? dict[APIClient.JSONResponseKeys.mediaURL]  as? String : ""
        uniqueKey = dict[APIClient.JSONResponseKeys.uniqueKey]  != nil ? dict[APIClient.JSONResponseKeys.uniqueKey] as? String : ""
        updatedAt = dict[APIClient.JSONResponseKeys.updatedAt]  != nil ? dict[APIClient.JSONResponseKeys.updatedAt] as? String : ""
        createdAt = dict[APIClient.JSONResponseKeys.createdAt]  != nil ? dict[APIClient.JSONResponseKeys.createdAt] as? String : ""
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInfo] {
        
        for result in results {
            Locations.shareInstance.studentLocations.append(StudentInfo(dict: result))
        }
        return Locations.shareInstance.studentLocations
    }
}
