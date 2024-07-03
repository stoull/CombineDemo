//
//  UITextField+Publisher.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import UIKit
import Combine

extension UITextField {
    var publisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap({ $0.object as? UITextField })  // 将通知的object转换成 UITextField
            .compactMap(\.text)     // 将通知的UITextField中的text取出，并移text为nil的对象
            .eraseToAnyPublisher()
    }
}
