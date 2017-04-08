//
//  Indicator.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation
import UIKit

final class Indicator: UIView {
    
    var activityIndicator = UIActivityIndicatorView()
    let heightActivityIndicator = CGFloat(40)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: heightActivityIndicator, height: heightActivityIndicator)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        activityIndicator.center.x = self.center.x
        activityIndicator.center.y = self.frame.height/2
        self.addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
