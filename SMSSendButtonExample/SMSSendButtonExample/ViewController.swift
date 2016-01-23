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
    
    var countdownTimer: NSTimer?
    
    var remainingSeconds: Int = 0 {
        willSet {
            sendButton.setTitle("验证码已发送(\(newValue)秒后重新获取)", forState: .Normal)
            
            if newValue <= 0 {
                sendButton.setTitle("重新获取验证码", forState: .Normal)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime:", userInfo: nil, repeats: true)
                
                remainingSeconds = 5
                
                sendButton.backgroundColor = UIColor.grayColor()
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
                sendButton.backgroundColor = UIColor.redColor()
            }
            
            sendButton.enabled = !newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        sendButton = UIButton()
        sendButton.frame = CGRect(x: 40, y: 100, width: view.bounds.width - 80, height: 40)
        sendButton.backgroundColor = UIColor.redColor()
        sendButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendButton.setTitle("获取验证码", forState: .Normal)
        sendButton.addTarget(self, action: "sendButtonClick:", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(sendButton)
    }
    
    func sendButtonClick(sender: UIButton) {
        isCounting = true
    }
    
    func updateTime(timer: NSTimer) {
        remainingSeconds -= 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

