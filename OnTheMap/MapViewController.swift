//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/5/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate ,CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var pinButton: UIBarButtonItem!
    
    var locationManager = CLLocationManager()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinOnMap()
    }

    @IBAction func refreshButtonPressed(_ sender: Any) {
        
        if Reachability.connectedToNetwork() {
            performUIUpdatesOnMain {
                self.mapView.removeAnnotations(APIClient.shareInstance.annotations)
                Locations.shareInstance.studentLocations.removeAll()
                APIClient.shareInstance.annotations.removeAll()
                self.pinOnMap()
            }
        } else {
            self.showAlert(title: "No Conection", message: "There is no internet connection available")
        }
        
    }
    @IBAction func pinButtonPressed(_ sender: Any) {
        if Reachability.connectedToNetwork(){
            if(APIClient.shareInstance.objectID == nil){
                self.performSegue(withIdentifier: "addPin", sender: self)
            }else{
                showAlertWithAction()
            }
        }else{
            showAlert(title: "No Internet Connectin", message: "You don't have internet connection available")
        }
    }
}


extension MapViewController : SetupProtocol {
    internal func mapSetting() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    internal func pinOnMap() {
        if Reachability.connectedToNetwork() {
            APIClient.shareInstance.getStudentLocations{ result,error in
                performUIUpdatesOnMain {
                    if let error = error{
                        print(error)
                        self.showAlert(title: "Not Working", message: "Snap! somthing went wrong.")
                    }else{
                        if let studentlocations = result{
                            Locations.shareInstance.studentLocations = studentlocations
                            var annotations = [MKPointAnnotation]()
                            for student in Locations.shareInstance.studentLocations{
                                guard let latitude = student.latitude, let longitude = student.longitude else{
                                    print("latitide and longitude not found")
                                    return
                                }
                                guard let name = student.firstName, let lastname = student.lastName ,  let url = student.mediaURL else{
                                    print("name,last name and url not fount")
                                    return
                                }
                                
                                let longitudeCL = CLLocationDegrees(longitude)
                                let latitudeCL = CLLocationDegrees(latitude)
                                let coordinate = CLLocationCoordinate2D(latitude: latitudeCL, longitude: longitudeCL)
                                
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = coordinate
                                annotation.title = "\(name) \(lastname)"
                                annotation.subtitle = url
                                annotations.append(annotation)
                            }
                            self.mapView.addAnnotations(annotations)
                        }
                    }
                }
            }
        }else {
            showAlert(title: "No Internet Connection", message: "It seems like you are don't have internet Connection")
        }
    }

    
}

extension MapViewController : MapViewProtocol{
    
    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusedId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reusedId) as? MKPinAnnotationView
        if(pinView == nil){
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reusedId)
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .red
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }

    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            let app = UIApplication.shared
            if let link = view.annotation?.subtitle!{
                app.open(URL(string: link)!, options: [:], completionHandler: nil)
            }
        }
    }
}

extension MapViewController : LocationManagerProtocol{
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)! , longitude: (location?.coordinate.longitude)! )
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }

    
}

fileprivate protocol MapViewProtocol {
     func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
     func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
}

fileprivate protocol LocationManagerProtocol{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
}

fileprivate protocol SetupProtocol {
    func mapSetting()
    func pinOnMap()
}
