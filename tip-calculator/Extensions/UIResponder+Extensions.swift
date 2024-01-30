//
//  UIResponder+Extensions.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 24/01/24.
//

import UIKit

extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
