//
//  APIClient.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import MapKit
class APIClient : NSObject{
    
    static let shareInstance = APIClient()
    
    var session = URLSession.shared
    var requestToken: String? = nil
    var objectID: String? = nil
    var sessionID: String? = nil
    var userID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var annotations = [MKPointAnnotation]()

    
    override init() {
        super.init()
    }
    
    func createSessionTask(jsonBody : [String:String], completionHandlerForSession:@escaping(_ result:AnyObject?,_ error:NSError?)-> Void) -> URLSessionDataTask{
        
        let userInfo = [JSONBodyKeys.udacityKey : jsonBody]
        
        var info: Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        }catch{
            print("couldn't encode data")
        }
        
        let request = NSMutableURLRequest(url: URL(string: Constants.getSessionURL + Methods.session)!)
        
        request.httpMethod = "POST"
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.acceptField)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
        let task = session.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForSession(nil, NSError(domain: "CreateSession", code: 1, userInfo: userInfo))
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                print("Your request returned a status code other than 2xx!")
                completionHandlerForSession(nil, NSError(domain: "CreateSession", code: 1, userInfo: userInfo))
                return
            }
            guard let data = data else{
                print("no data found")
                return
            }
            let range = Range(uncheckedBounds: (5,data.count))
            let newData = data.subdata(in: range)
            print(NSString(data:newData, encoding:String.Encoding.utf8.rawValue)!)
            self.convertData(newData, completionHandlerForConvertData: completionHandlerForSession)
        }
        task.resume()
        return task
    }
    
    func taskForGetMethod(_ method:String, _ parameters : [String:AnyObject], completionHandlerForGetMethod: @escaping(_ result:AnyObject?,_ error: NSError?) -> Void) -> URLSessionDataTask{
        var paramerters = parameters
        print(parseURLFromParameters(parameters, withPathExtension: method))
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters,withPathExtension: method))
        request.addValue(ParseParameterValues.apiKey, forHTTPHeaderField: HTTPHeaderField.parseRestApiKey)
        request.addValue(ParseParameterValues.appID, forHTTPHeaderField: HTTPHeaderField.parseAppID)
        
        let task = session.dataTask(with: request as URLRequest){ data,response,error in
            
            func handleError (_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetMethod(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else{
                handleError((error?.localizedDescription)!)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                handleError("Status code is other than 2XX")
                return
            }
            
            guard let data = data else{
                handleError("data not found")
                return
            }
            self.convertData(data, completionHandlerForConvertData: completionHandlerForGetMethod)
        }

        task.resume()
        return task
    }
    
    func parseURLFromParameters(_ parameters: [String: AnyObject], withPathExtension:String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.apiScheme
        components.host = Constants.apiHost
        components.path = Constants.apiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print(components.url!)
        return components.url!
    }
    
    private func convertData(_ data: Data, completionHandlerForConvertData: (_ result:AnyObject?,_ error: NSError?) -> Void) {
        var parsedData:AnyObject!
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            if JSONSerialization.isValidJSONObject(parsedData) {
                completionHandlerForConvertData(parsedData, nil)
            }
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Cannot parse the \(data) into json Format"]
            completionHandlerForConvertData(nil,NSError(domain:"convertDataWithCompletionHandler", code:1,userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedData,nil)
    }
    
    func taskForGetUserInfo(completionHandlerForUserInfo: @escaping(_ result : AnyObject?, _ error : NSError?) -> Void){
        let urlString = Constants.getSessionURL + Methods.users + "\(userID)"
        
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        
        let task = session.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForUserInfo(nil, NSError(domain: "Get User Info", code: 1, userInfo: userInfo))
            }else{
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    print("status code is other than 2XX")
                    return
                }
                
                guard let data = data else{
                    print("no data was found")
                    return
                }
                let range = Range(uncheckedBounds: (5,data.count))
                let newData = data.subdata(in: range)
                print(NSString(data:newData, encoding:String.Encoding.utf8.rawValue)!)
                self.convertData(newData, completionHandlerForConvertData: completionHandlerForUserInfo)
            }
        }
        task.resume()
    }
    
    
    func taskForPostSudentLocation(_ jsonBody: [String:AnyObject], method:String, completionHandlerForPostLocation:@escaping(_ result:AnyObject?,_ error: NSError?)->Void)-> URLSessionDataTask{
        let userInfo = jsonBody
        var info:Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        }catch{
            print("Couldn't convert to json")
        }
        let url = parseURLFromParameters([:], withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(HTTPHeaderField.parseAppID, forHTTPHeaderField: ParseParameterValues.apiKey)
        request.addValue(HTTPHeaderField.parseRestApiKey, forHTTPHeaderField:ParseParameterValues.appID)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
        let task = session.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPostLocation(nil, NSError(domain: "POST Location", code: 1, userInfo: userInfo))
            }else{
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    print("status code is other than 2XX")
                    return
                }
                guard let data = data else {
                    print("data not found")
                    return
                }
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range)
                self.convertData(newData, completionHandlerForConvertData: completionHandlerForPostLocation)
            }
        }
        task.resume()
        return task
        
    }
    
    func taskForPutStudentLocation(_ jsonBody:[String:AnyObject],method:String,completionHandlerForPutLocation:@escaping(_ result: AnyObject?,_ error: NSError?)-> Void)-> URLSessionDataTask{
        let userInfo = jsonBody
        var info:Data!
        do{
            info = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        }catch{
            print("Couldn't convert to json")
        }
        let url = parseURLFromParameters([:], withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue(HTTPHeaderField.parseAppID, forHTTPHeaderField: ParseParameterValues.apiKey)
        request.addValue(HTTPHeaderField.parseRestApiKey, forHTTPHeaderField:ParseParameterValues.appID)
        request.addValue(Constants.applicationJSON, forHTTPHeaderField: HTTPHeaderField.contentType)
        request.httpBody = info
        
        let task = session.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPutLocation(nil, NSError(domain: "POST Location", code: 1, userInfo: userInfo))
            }else{
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else{
                    print("status code is other than 2XX")
                    return
                }
                guard let data = data else {
                    print("data not found")
                    return
                }
                let range = Range(uncheckedBounds: (5, data.count))
                let newData = data.subdata(in: range)
                self.convertData(newData, completionHandlerForConvertData: completionHandlerForPutLocation)
            }
        }
        task.resume()
        return task

    }
    

}
