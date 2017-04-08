//
//  Networking.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
extension APIClient{
    func createSession(username: String, password : String, completetionHandleForSession:@escaping(_ success: Bool, _ result: AnyObject?, _ error: NSError?)-> Void){
        let dictionary = [JSONBodyKeys.userNameKey : username,
                          JSONBodyKeys.passwordKey : password]
        _ = createSessionTask(jsonBody: dictionary){ (results,error) in
            
            if error != nil {
                completetionHandleForSession(false,nil,error)
            } else {
                if let result = results as? [String:AnyObject]{
                    if let account = result[JSONResponseKeys.account] as? [String:AnyObject]{
                        if let userID = account[JSONResponseKeys.key] as? String{
                            APIClient.shareInstance.userID = userID
                            print("\(userID)")
                        }
                    }
                    if let session = result[JSONResponseKeys.session] as? [String:AnyObject]{
                        if let sessionID = session[JSONResponseKeys.sessionId] as? String{
                            APIClient.shareInstance.sessionID = sessionID
                            print("\(sessionID)")
                        }
                    }
                    completetionHandleForSession(true,result as AnyObject?,nil)
                } else{
                    completetionHandleForSession(false, nil, NSError(domain: "createSession", code:1, userInfo: [NSLocalizedDescriptionKey: "Could not parse the data"]))
                }
            }
        }
    }
    
    func getStudentLocations(_ completionHandlerForStudentLocations: @escaping(_ result:[StudentInfo]?,_ error:NSError?)-> Void){
        
        let parameter : [String: AnyObject] = [ParseParameterKeys.limit: ParseParameterValues.limit as AnyObject,
                                               ParseParameterKeys.order: ParseParameterValues.order as AnyObject]
        
        let method = Methods.studentLocations
        
        let _ = taskForGetMethod(method, parameter){ result,error in
            if let error = error{
                completionHandlerForStudentLocations(nil, error)
            }else{
                if let result = result?[APIClient.JSONResponseKeys.results] as? [[String:AnyObject]]{
                    let students = StudentInfo.locationsFromResults(result)
                    for result in result {
                        if let userID = result[JSONResponseKeys.uniqueKey] as? String , userID == self.userID {
                            guard let firstName = result[JSONResponseKeys.firstName] as? String else {
                                print("Cannot find key 'firstName' in \(result)")
                                return
                            }
                            guard let lastName = result[JSONResponseKeys.lastName] as? String else {
                                print("Cannot find key 'lastName' in \(result)")
                                return
                            }
                            guard let objectID = result[JSONResponseKeys.objectID] as? String else {
                                print("Cannot find key 'objectID' in \(result)")
                                return
                            }
                            self.firstName = firstName
                            self.lastName = lastName
                            self.objectID = objectID
                        }
                    }
                    completionHandlerForStudentLocations(students,nil)
                } else {
                    completionHandlerForStudentLocations(nil,NSError(domain: "getStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey : "Couldn't find the result"]))
                }
            }
        }
        
    }
    
    func getUserInfo(_ completionHandlerForUserInfo: @escaping(_ result: AnyObject?, _ error: Error?) -> Void){
        taskForGetUserInfo(){ result,error in
            if error != nil {
                completionHandlerForUserInfo(nil,error)
            }else{
                if let resultDictionary = result as? [String : AnyObject] {
                    if let userDictionary = resultDictionary["user"] as? [String : AnyObject] {
                        
                        if let firstName = userDictionary["nickname"] as? String {
                            APIClient.shareInstance.firstName = firstName
                        }
                        if let lastName = userDictionary["last_name"] as? String {
                            APIClient.shareInstance.lastName = lastName
                        }
                        
                        completionHandlerForUserInfo(result, nil)
                    }
                } else {
                    completionHandlerForUserInfo(nil, NSError(domain: "UserInfo", code: 1, userInfo:[NSLocalizedDescriptionKey:"Could not parse the data"]))
                }
            }
        }
    }
    
    func postStudentLocation(_ json: [String:AnyObject], completionHandlerForPostLocation: @escaping(_ result:AnyObject?, _ error: NSError?) -> Void){
        let _ = taskForPostSudentLocation(json, method: Methods.studentLocations){ result,error in
            if error != nil {
                completionHandlerForPostLocation(nil,error)
            }else{
                if let result = result as? [String:AnyObject] {
                    if let objectID = result[JSONResponseKeys.objectID] as? String {
                        APIClient.shareInstance.objectID = objectID
                        print ("Object ID = \(objectID)")
                    }
                    completionHandlerForPostLocation(result as AnyObject?, nil)
                } else {
                    completionHandlerForPostLocation(nil, NSError(domain: "postStudentLocation parsing", code: 1, userInfo:[NSLocalizedDescriptionKey: "Could not parse the data"]))
                }
            }
        }
    }
    func updateStudentLocation (_ json: [String:AnyObject], completionHandlerForUpdateLocation: @escaping(_ result:AnyObject?, _ error: NSError?) -> Void){
        let methodString = "/\(APIClient.shareInstance.objectID)"
        let _ = taskForPutStudentLocation(json, method: methodString) { result,error in
            if error != nil {
                completionHandlerForUpdateLocation(nil,error)
            }else{
                if let result = result{
                    completionHandlerForUpdateLocation(result, nil)
                }else{
                    completionHandlerForUpdateLocation(nil,NSError(domain: "updateStudentLocation", code: 1, userInfo:[NSLocalizedDescriptionKey: "Cannot parse the data"]))
                }
            }
        }
    }
}
