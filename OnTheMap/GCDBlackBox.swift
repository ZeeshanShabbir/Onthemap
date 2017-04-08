//
//  Constants.swift
//  OnTheMap
//
//  Created by Muhammad Zeeshan Shabbir on 4/4/17.
//  Copyright © 2017 Muhammad Zeeshan Shabbir. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
