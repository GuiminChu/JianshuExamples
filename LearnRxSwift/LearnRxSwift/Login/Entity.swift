//
//  Entity.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/3/25.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import Moya

// MARK: - User
struct User {
    let name: String
    let userToken: String
}

// MARK: - ResponseResult
enum ResponseResult {
    case success(user: User)
    case faild(message: String)
    
    var user: User? {
        switch self {
        case .success(let user):
            return user
        case .faild:
            return nil
        }
    }
}

// MARK: - RequestTarget
enum RequestTarget {
    case login(phoneNumber: String, password: String)
}

extension RequestTarget: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://101.200.229.53/RunManage/run")!
    }
    
    var path: String {
        return "/phone.inf"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .login(let phoneNumber, let password):
            return ["phoneNumber": phoneNumber, "password": password, "type": "login"]
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var task: Task {
        return .request
    }
    
    var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    var sampleData: Data {
        switch self {
        case .login:
            return "".data(using: String.Encoding.utf8)!
        }
    }
}
