//
//  Alerts.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController: Alerts {
    

    internal func showAlert(title: String, message: String?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default){ UIAlertAction in }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    internal func showAlertWithAction() {
        let alertController = UIAlertController(title: "", message: "You Have Already Posted a Student Location. Would You Like to Overwrite Your Current Location?", preferredStyle: .alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default) { action -> Void in
            self.performSegue(withIdentifier: "addPin", sender: self)
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel Selected")
        }
        alertController.addAction(overwriteAction)
        alertController.addAction(cancelButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
protocol Alerts{
    func showAlert(title: String, message : String?)
    func showAlertWithAction()
    

}
