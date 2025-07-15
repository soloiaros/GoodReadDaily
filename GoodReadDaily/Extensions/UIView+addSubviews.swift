//
//  UIView+addSubviews.swift
//  GoodReadDaily
//
//  Created by Alex on 7/14/25.
//

import UIKit

extension UIView {
    
    // Adding Multiple Subviews at Once
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
