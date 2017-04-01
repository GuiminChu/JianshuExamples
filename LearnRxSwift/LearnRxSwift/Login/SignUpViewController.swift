//
//  SignUpViewController.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let viewModel = SignUpViewModel()
        
        // 账号
        usernameTextField.rx.text.orEmpty
            .bindTo(viewModel.username)
            .addDisposableTo(disposeBag)
        
        viewModel.usernameUsable
            .bindTo(usernameLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        viewModel.usernameUsable
            .bindTo(passwordTextField.rx.inputEnabled)
            .addDisposableTo(disposeBag)
        
        // 密码
        passwordTextField.rx.text.orEmpty
            .bindTo(viewModel.password)
            .addDisposableTo(disposeBag)
        
        viewModel.passwordUsable
            .bindTo(passwordLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        // 确定密码
        repeatPasswordTextField.rx.text.orEmpty
            .bindTo(viewModel.repeatPassword)
            .addDisposableTo(disposeBag)
        
        viewModel.repeatPasswordUsable
            .bindTo(repeatPasswordLabel.rx.validationResult)
            .addDisposableTo(disposeBag)
        
        // 注册
        viewModel.registerButtonEnabled.subscribe(onNext: { [weak self] valid in
            self?.registerButton.isEnabled = valid
            self?.registerButton.alpha = valid ? 1.0: 0.5
        }).addDisposableTo(disposeBag)
        
        registerButton.rx.tap
            .bindTo(viewModel.registerTaps)
            .addDisposableTo(disposeBag)
        
        viewModel.registerResult.subscribe(onNext: { [weak self] result in
            switch result {
            case .ok(let message):
                self?.showAlert(message: message)
            case .failed(let message):
                self?.showAlert(message: message)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }
    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }
}
