//
//  SignUpViewModel.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/3/23.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import RxSwift

class SignUpViewModel {
    
    let username = Variable<String>("")
    let password = Variable<String>("")
    let repeatPassword = Variable<String>("")
    
    let usernameUsable: Observable<Result>
    let passwordUsable: Observable<Result>
    let repeatPasswordUsable: Observable<Result>
    
    let registerTaps = PublishSubject<Void>()
    
    let registerButtonEnabled: Observable<Bool>
    let registerResult: Observable<Result>
    
    init() {
        let service = ValidationService.instance
        
        usernameUsable = username
            .asObservable()
            .flatMapLatest({ username in
                return service.validateUsername(username: username).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "username检测出错"))
            })
            .shareReplay(1)
        
        passwordUsable = password
            .asObservable()
            .map({ password in
            return service.validatePassword(password: password)
        }).shareReplay(1)
        
        repeatPasswordUsable = Observable.combineLatest(password.asObservable(), repeatPassword.asObservable()) { return service.validateRepeatedPassword(password: $0, repeatedPassword: $1) }.shareReplay(1)
        
        registerButtonEnabled = Observable.combineLatest(usernameUsable, passwordUsable, repeatPasswordUsable) { (username, password, repeatPassword) in
                username.isValid && password.isValid && repeatPassword.isValid
            }
            .distinctUntilChanged()
            .shareReplay(1)
        
        let usernameAndPassword = Observable.combineLatest(username.asObservable(), password.asObservable()) { ($0, $1) }
        
        registerResult = registerTaps.asObservable().withLatestFrom(usernameAndPassword).flatMapLatest({ (username, password) in
            return service.register(username: username, password: password).observeOn(MainScheduler.instance).catchErrorJustReturn(Result.failed(message: "注册出错"))
        }).shareReplay(1)
    }
}
