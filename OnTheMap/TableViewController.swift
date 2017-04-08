//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/5/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit
class TableViewController : UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Locations.shareInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let student = Locations.shareInstance.studentLocations[(indexPath as NSIndexPath).row] as StudentInfo
        if student.firstName == "" && student.lastName == "" {
            cell.label.text = ""
        } else {
            cell.label.text = "\(student.firstName ?? "") \(student.lastName ?? "")"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let studentLocation = Locations.shareInstance.studentLocations[(indexPath as NSIndexPath).row] as StudentInfo
        let urlString = studentLocation.mediaURL!
        let app = UIApplication.shared
        if urlString != "" {
            app.open(URL(string: urlString)!, options: [:], completionHandler: nil)
        } else {
            showAlert(title: "No Url", message: "This dumb user hasn't shared his profile")
        }
    }
    
    @IBAction func refreshTheTable(_ sender: Any) {
        if Reachability.connectedToNetwork() {
            Locations.shareInstance.studentLocations.removeAll()
            getStudentLocations()
        } else {
            self.showAlert(title: "No Internet", message: "You don't have internet connection")
        }
    }
    @IBAction func addPinOnMap(_ sender: Any) {
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


extension TableViewController:ApiProtocol{
    internal func getStudentLocations() {
        if Reachability.connectedToNetwork(){
            APIClient.shareInstance.getStudentLocations(){ result,error in
                if let result = result{
                    Locations.shareInstance.studentLocations = result
                    self.tableView.reloadData()
                }else{
                    if error != nil {
                        self.showAlert(title: "Snap", message: "Something went wrong")
                    }
                }
            }
        }else {
            showAlert(title: "No internet", message: "You don't have internet Connection")
        }
    }
}

protocol ApiProtocol {
    func getStudentLocations()
}
