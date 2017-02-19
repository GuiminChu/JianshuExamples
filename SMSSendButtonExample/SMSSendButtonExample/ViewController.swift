//
//  ViewController.swift
//  SMSSendButtonExample
//
//  Created by ChuGuimin on 16/1/23.
//  Copyright © 2016年 cgm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var sendButton: UIButton!
    
    var countdownTimer: Timer?
    
    var remainingSeconds: Int = 0 {
        willSet {
            sendButton.setTitle("验证码已发送(\(newValue)秒后重新获取)", for: .normal)
            
            if newValue <= 0 {
                sendButton.setTitle("重新获取验证码", for: .normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTime(_:)), userInfo: nil, repeats: true)
                
                remainingSeconds = 5
                
                sendButton.backgroundColor = UIColor.gray
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                sendButton.backgroundColor = UIColor.red
            }
            
            sendButton.isEnabled = !newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sendButton = UIButton()
        sendButton.frame = CGRect(x: 40, y: 100, width: view.bounds.width - 80, height: 40)
        sendButton.backgroundColor = UIColor.red
        sendButton.setTitleColor(UIColor.white, for: .normal)
        sendButton.setTitle("获取验证码", for: .normal)
        sendButton.addTarget(self, action: #selector(ViewController.sendButtonClick(_:)), for: .touchUpInside)
        
        self.view.addSubview(sendButton)
    }
    
    func sendButtonClick(_ sender: UIButton) {
        isCounting = true
    }
    
    func updateTime(_ timer: Timer) {
        remainingSeconds -= 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

