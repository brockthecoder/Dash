//
//  Extensions.swift
//  CoreMotionDashboard
//
//  Created by brock davis on 3/26/23.
//

import UIKit

extension UIView {
    
    func addSubview<T: UIView>(_ view: T, configurations: (T) -> ()) {
        self.addSubview(view)
        configurations(view)
    }
}
