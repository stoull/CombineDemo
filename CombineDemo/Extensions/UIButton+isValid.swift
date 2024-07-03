//
//  UIButton+isValid.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import UIKit

extension UIButton {
    var isValid: Bool {
        get { return self.isEnabled }
        set {
            isEnabled = newValue
            backgroundColor = newValue ? .valid : .invalid
        }
    }
}
