//
//  ImagePickerViewController.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 2017/3/28.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON

class ImagePickerViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        return imagePicker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        galleryButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .photoLibrary
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
                
            })
            .addDisposableTo(disposeBag)
        
        cameraButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                if let strongSelf = self {
                    strongSelf.imagePicker.sourceType = .camera
                    strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
                }
                
            })
            .addDisposableTo(disposeBag)
        
        uploadButton.rx.tap
            .subscribe(onNext: {
                
                let data = animatedBirdData()
                GiphyProvider.request(Giphy.upload(gif: data), completion: { result in
                    switch result {
                    case let .success(moyaResponse):
                        
                        print(moyaResponse.description)
                        let json = JSON(data: moyaResponse.data)
                        print(json)
                    // do something with the response data or statusCode
                    case let .failure(error):
                        print(error)
                    }
                })
                
                
//                RxProvider.request(ImagePicker.ad, completion: { result in
//                    switch result {
//                    case let .success(moyaResponse):
//                        
//                        print(moyaResponse.description)
//                        let json = JSON(data: moyaResponse.data)
//                        print(json)
//                    // do something with the response data or statusCode
//                    case let .failure(error):
//                        print(error)
//                    }
//                })
            })
            .addDisposableTo(disposeBag)
        
        
    }
}

// MARK: UIImagePicker

extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        imageView.image = image
        activityIndicator.startAnimating()
        
        let resizeImage = image.largestCenteredSquareImage().resizeToTargetSize(CGSize(width: 400.0, height: 400.0))
        let imageData = UIImageJPEGRepresentation(resizeImage, 0.7)
        
        if let imageData = imageData {
            
            print("x")
            
//            GiphyProvider.request(Giphy.upload(gif: imageData), completion: { result in
//                switch result {
//                case let .success(moyaResponse):
//                    
//                    print(moyaResponse.description)
//                    let json = JSON(data: moyaResponse.data)
//                    print(json)
//                // do something with the response data or statusCode
//                case let .failure(error):
//                    print(error)
//                }
//            })

//            RxProvider.request(ImagePicker.uploadAvatar(userId: "2055", image: imageData), completion: { result in
//                switch result {
//                case let .success(moyaResponse):
//                    
//                    print(moyaResponse.description)
//                    let json = JSON(data: moyaResponse.data)
//                    print(json)
//                // do something with the response data or statusCode
//                case let .failure(error):
//                    print(error)
//                }
//            })
            
//            RxProvider.request(ImagePicker.uploadAvatar(userId: "2055", image: imageData)).subscribe(onNext: { response in
//                print("com")
//            }, onError: { error in
//                print(error)
//            }, onCompleted: {
//                print("completed")
//            }).dispose()
//
            RxProvider.request(ImagePicker.uploadAvatar(userId: "2055", image: imageData)).subscribe({ event in
                switch event {
                case .next(let response):
                    print(response.description)
                    
                case .error(let error):
                    print(error)
                    print("error")
                case .completed:
                    print("completed")
                }
            }).addDisposableTo(disposeBag)
            
        }
    }
}
