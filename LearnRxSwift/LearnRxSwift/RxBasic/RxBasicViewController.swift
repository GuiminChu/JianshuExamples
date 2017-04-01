//
//  RxBasicViewController.swift
//  LearnRxSwift
//
//  Created by Chu Guimin on 17/1/18.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftRandom

/// 自定义的错误
///
/// - notPositive: 不是正数
/// - oversize: 数字过大
enum MyError: Swift.Error {
    case notPositive(value: Int)
    case oversize(value: Int)
    case dummyError
    case dummyError1
    case dummyError2
    
    var errorDescription: String? {
        switch self {
        case .notPositive(let value):
            return "\(value)不是正数"
        case .oversize(let value):
            return "\(value)过大"
        default:
            return "其他错误"
        }
    }
}

class RxBasicViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var retryWhenButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let firstName = firstNameTextField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).map({ $0 ?? "" })
        let lastName  = lastNameTextField.rx.text.throttle(0.5, scheduler: MainScheduler.instance).map({ $0 ?? "" })
        Observable.combineLatest(firstName, lastName) { $0 + " " + $1 }
            .map { "Greeting \($0)" }
            .bindTo(greetingLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        button.rx.tap.subscribe(onNext: {
            print("click")
            
            Observable<Int>.from([1, 2, 3, -1, 5]).map({ value -> Int in
                if value > 0 {
                    return value
                } else {
                    throw MyError.dummyError1
                }
            }).debug().subscribe().dispose()
            
            Observable<Int>.from([1, 2, 3, -1, 5]).flatMap({ value in
                
                Observable.just(value).map({ value -> Int in
                    if value > 0 {
                        return value
                    } else {
                        throw MyError.dummyError2
                    }
                }).catchErrorJustReturn(4)
            }).debug().subscribe().dispose()
            
        }).addDisposableTo(disposeBag)
        
        retryWhenButton.rx.tap.subscribe(onNext: {
            
            Observable<Int>.deferred({ () -> Observable<Int> in
                return Observable.just(Int.random(-100, 200))
            }).map({ value -> Int in
                if value <= 0 {
                    throw MyError.notPositive(value: value)
                } else if value > 100 {
                    throw MyError.oversize(value: value)
                } else {
                    return value
                }
            }).catchError({ error -> Observable<Int> in
                return Observable.create({ [unowned self] observer in
                    let alert = UIAlertController(title: "错误，重试还是使用默认值 1 替换？", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "重试", style: .cancel, handler: { _ in
                        observer.on(Event<Int>.error(error))
                    }))
                    alert.addAction(UIAlertAction(title: "替换", style: .default, handler: { _ in
                        observer.on(.next(1))
                        observer.on(.completed)
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return Disposables.create {
                        alert.dismiss(animated: true, completion: nil)
                    }
                })
            }).retry().debug().subscribe().dispose()
            
        }).addDisposableTo(disposeBag)
        
        let tapBackground = UITapGestureRecognizer()
        tapBackground.rx.event.subscribe { [weak self] _ in
            self?.view.endEditing(true)
        }.addDisposableTo(disposeBag)
        view.addGestureRecognizer(tapBackground)
        
        
        practice()
    }
    
    func practice() {
        print("========= never =========")
        let neverSequence = Observable<String>.never()
        neverSequence.subscribe { _ in
            print("never")
        }.addDisposableTo(disposeBag)
        
        print("")
        
        print("========= empty =========")
        Observable<Int>.empty().subscribe { event in
            print(event)
        }.addDisposableTo(disposeBag)
        
        print("")
        
        print("========= just =========")
        Observable.just("jjj").subscribe { e in
            print(e)
        }.addDisposableTo(disposeBag)
        Observable.just("j1j").subscribe(onNext: { element in
            print(element)
        }).addDisposableTo(disposeBag)
        
        print("")
        
        print("========= of =========")
        Observable.of("1", "2", "3", "4").subscribe(onNext: { element in
            print(element)
        }).addDisposableTo(disposeBag)
        
        print("")
        
        print("========= creat =========")
        let myCreat = Observable<String>.create { observer in
            observer.on(Event<String>.next("1"))
            observer.on(Event<String>.completed)
            
            return Disposables.create()
        }
        myCreat.subscribe { e in
            print(e)
        }.addDisposableTo(disposeBag)
        
        print("")
        
        print("========= retry =========")
        var count = 1
        let myRetry = Observable<String>.create { observer in
            observer.on(Event<String>.next("1"))
            observer.on(Event<String>.next("2"))
            
            if count == 1 || count == 2 {
                observer.on(Event<String>.error(MyError.dummyError))
                print("error")
                count += 1
            }
            
            observer.on(Event<String>.next("3"))
            observer.on(Event<String>.next("4"))
            observer.on(Event<String>.completed)
            
            return Disposables.create()
        }
        myRetry.retry(2).subscribe { e in
            print(e)
            }.addDisposableTo(disposeBag)
        
        print("")
        
        print("========= repeat =========")
        Observable.repeatElement("1024").take(3).subscribe { e in
            print(e)
        }.addDisposableTo(disposeBag)
        
        print("")
        
        print("========= doOn =========")
        Observable.of("1", "2", "3", "4").do(onNext: { s in
            print("doOn\(s)")
        }, onError: { e in
            print("doOn\(e)")
        }, onCompleted: { 
            print("doOn Completed")
        }).subscribe(onNext: { s in
            print(s)
        }, onError: { e in
            print(e)
        }, onCompleted: { 
            print("completed")
        }).addDisposableTo(disposeBag)
    }
    
    func practice1() {
        print("========= variable =========")
        let variable = Variable("z")
        variable.asObservable().subscribe { e in
            print(e)
        }.addDisposableTo(disposeBag)
        variable.value = "1"
        variable.value = "2"
    }
    
    func practice2() {
        print("========= flatMap =========")
        let x = Player(score: Variable(100))
        let player = Variable(x)
        
        player.asObservable().flatMap({ $0.score.asObservable() })
            .subscribe(onNext: { element in
            print(element)
        }).addDisposableTo(disposeBag)
        
        x.score.value = 90
        player.value = Player(score: Variable(80))
        
    }
}

struct Player {
    var score: Variable<Int>
}


