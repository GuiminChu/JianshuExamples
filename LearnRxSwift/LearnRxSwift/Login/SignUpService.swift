//
//  SignUpService.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/3/25.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import RxSwift

class ValidationService {
    static let instance = ValidationService()
    
    private init() {}
    
    let minCharactersCount = 6
    
    // 这里面我们返回一个Observable对象，因为我们这个请求过程需要被监听。
    func validateUsername(username: String) -> Observable<Result> {
        if username.characters.count == 0 {
            return Observable.just(.empty)
        }
        
        if username.characters.count < minCharactersCount {
            return Observable.just(.failed(message: "至少六个字符"))
        }
        
        if usernameValid(username: username) {
            return Observable.just(.failed(message: "账号已存在"))
        }
        
        return Observable.just(.ok(message: "用户名可用"))
    }
    
    func usernameValid(username: String) -> Bool {
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        guard let userDic = NSDictionary(contentsOfFile: filePath) else {
            return false
        }
        let usernameArray = userDic.allKeys as NSArray
        if usernameArray.contains(username) {
            return true
        } else {
            return false
        }
    }
    
    func validatePassword(password: String) -> Result {
        if password.characters.count == 0 {
            return .empty
        }
        
        if password.characters.count < minCharactersCount {
            return .failed(message: "密码长度至少六个字符")
        }
        
        return .ok(message: "密码可用")
    }
    
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> Result {
        if repeatedPassword.characters.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "密码可用")
        }
        
        return .failed(message: "两次密码不一致")
    }
    
    func register(username: String, password: String) -> Observable<Result> {
        let userDic = [username: password]
        
        let filePath = NSHomeDirectory() + "/Documents/users.plist"
        
        if (userDic as NSDictionary).write(toFile: filePath, atomically: true) {
            return Observable.just(Result.ok(message: "注册成功"))
        }
        
        return Observable.just(Result.failed(message: "注册失败"))
    }
}
