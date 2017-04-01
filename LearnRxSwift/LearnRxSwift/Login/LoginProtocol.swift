//
//  LoginProtocol.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import RxSwift
import RxCocoa

enum Result {
    case ok(message: String)
    case empty
    case failed(message: String)
}

extension Result {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

extension Result {
    var textColor: UIColor {
        switch self {
        case .ok:
            return .green
        case .empty:
            return .black
        case .failed:
            return .red
        }
    }
}

extension Result {
    var description: String {
        switch self {
        case .ok(let message):
            return message
        case .empty:
            return ""
        case .failed(let message):
            return message
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: UIBindingObserver<Base, Result> {
        return UIBindingObserver(UIElement: base, binding: { (label, result) in
            label.textColor = result.textColor
            label.text = result.description
        })
    }
}

extension Reactive where Base: UITextField {
    var inputEnabled: UIBindingObserver<Base, Result> {
        return UIBindingObserver(UIElement: base, binding: { (textFiled, result) in
            textFiled.isEnabled = result.isValid
        })
    }
}
