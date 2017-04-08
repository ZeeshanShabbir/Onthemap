//
//  UIController+Indicator.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit

private var indicator: Indicator?

protocol activityIndicatorDelegate {
    func showActivityIndicator()
    func hideActivityIndicator()
}

extension UIViewController: activityIndicatorDelegate {
    
    internal func showActivityIndicator() {
        if indicator?.superview != nil {
            indicator?.removeFromSuperview()
        }
        indicator = Indicator(frame: screenBounds())
        indicator?.activityIndicator.startAnimating()
        indicator?.alpha = 1
        self.view.addSubview(indicator!)
    }
    
    internal func hideActivityIndicator() {
        indicator?.activityIndicator.stopAnimating()
    }
    
    func screenBounds() -> CGRect {
        return UIScreen.main.bounds
    }
}
