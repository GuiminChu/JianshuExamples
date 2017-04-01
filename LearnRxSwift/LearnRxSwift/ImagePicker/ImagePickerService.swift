//
//  ImagePickerService.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 2017/3/28.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import Foundation
import Alamofire
import Moya
import RxSwift

let RxProvider = RxMoyaProvider<ImagePicker>()

public enum ImagePicker {
    case uploadAvatar(userId: String, image: Data)
    case ad
}

extension ImagePicker: TargetType {
    
    public var baseURL: URL {
        return URL(string: "http://imstlife.com.cn/RunManage/run")!
    }
    
    public var path: String {
        switch self {
        case .uploadAvatar:
            return "/updateHeadImg.inf"
        case .ad:
            return "/getAd.inf"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var parameters: [String : Any]? {
        switch self {
        case let .uploadAvatar(userId, _):
            return ["userId": userId]
        case .ad:
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var task: Task {
        switch self {
        case .ad:
            return .request
        case let .uploadAvatar(_,image):
//            let formData: [Moya.MultipartFormData] = [MultipartFormData(provider: .data(image), name: "file", fileName: "photo.jpg", mimeType: "image/jpeg")]
//            return .upload(UploadType.multipart(formData))
            return .upload(.multipart([MultipartFormData(provider: .data(image), name: "file", fileName: "avatar.jpg", mimeType: "image/jpeg")]))
        }
    }
    
    public var validate: Bool {
        switch self {
        default:
            return false
        }
    }
    
    public var sampleData: Data {
        switch self {
        default:
            return "".data(using: String.Encoding.utf8)!
        }
    }
}
