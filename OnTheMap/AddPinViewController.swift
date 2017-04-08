//
//  AddPinViewController.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/6/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AddPinViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var enterLocation: UITextField!
    
    @IBOutlet weak var bottomview: UIView!
    
    @IBOutlet weak var enterLink: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var coordinates: CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomview.isHidden = true
    }
    
    func setUpUI(){
        enterLocation.delegate = self
        enterLink.delegate = self
    }
    
    
    @IBAction func showOnMapPressed(_ sender: Any) {
        if Reachability.connectedToNetwork() {
            showActivityIndicator()
            topview.isHidden = true
            bottomview.isHidden = false
            findMyLocation()
        } else {
            self.showAlert(title: "No Internet Connection", message: "You don't have internet connect avaiable")
        }
        
    }
    @IBAction func CancelTop(_ sender: Any) {
        enterLocation.text = ""
        enterLink.text = ""
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func CancelBottom(_ sender: Any) {
        enterLocation.text = ""
        enterLink.text = ""
        bottomview.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitBtnPressed(_ sender: Any) {
        print("pressed")
        submitMyLocation()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddPinViewController : MapKitProtocol{
    internal func findMyLocation() {
        if enterLocation.text != nil {
            self.hideActivityIndicator()
            let location = enterLocation.text
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(location!){ marks,error in
                if error != nil {
                    self.showAlert(title: "Couldn't find location", message: "Please enter the valid location and try again")
                }else{
                    if let mark = marks?.first, let location = mark.location {
                        let pointAnnotation: MKPointAnnotation = MKPointAnnotation()
                        pointAnnotation.coordinate = location.coordinate
                        self.mapView?.addAnnotation(pointAnnotation)
                        self.mapView?.centerCoordinate = location.coordinate
                        self.mapView?.camera.altitude = 20000
                        self.coordinates = location.coordinate
                    }
                }
            }
        }
    }

    internal func submitMyLocation() {
        APIClient.shareInstance.getUserInfo(){ result,error in
            if error != nil{
                print(error)
            }else{
                let studentInfo:[String:AnyObject] = [
                    APIClient.JSONResponseKeys.firstName : APIClient.shareInstance.firstName as AnyObject,
                    APIClient.JSONResponseKeys.lastName  : APIClient.shareInstance.lastName as AnyObject,
                    APIClient.JSONResponseKeys.mapString : self.enterLocation.text as AnyObject,
                    APIClient.JSONResponseKeys.mediaURL  : self.enterLink.text as AnyObject,
                    APIClient.JSONResponseKeys.latitude  : self.coordinates.latitude.description as AnyObject,
                    APIClient.JSONResponseKeys.longitude : self.coordinates.longitude.description as AnyObject,
                    APIClient.JSONResponseKeys.uniqueKey : APIClient.shareInstance.uniqueKey as AnyObject
                ]

            
                if APIClient.shareInstance.objectID != nil {
                    //update the location
                    APIClient.shareInstance.postStudentLocation(studentInfo){ result,error in
                        if error != nil {
                            print (error!)
                        }
                        if let results = result as? [String:AnyObject] {
                            print(results[APIClient.JSONResponseKeys.createdAt]!)
                        }
                        performUIUpdatesOnMain {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }else{
                    //post the location
                    APIClient.shareInstance.updateStudentLocation(studentInfo){ result,error in
                        if error != nil {
                            print(error!)
                        }
                        if let results = result as? [String:AnyObject] {
                            let objectId = results[APIClient.JSONResponseKeys.objectID] as? String
                            print(results[APIClient.JSONResponseKeys.createdAt]!)
                            print(objectId!)
                            APIClient.shareInstance.objectID = objectId!
                            performUIUpdatesOnMain {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

    
}

fileprivate protocol MapKitProtocol {
    func findMyLocation()
    func submitMyLocation()
}
