//
//  ViewController.swift
//  CustomPresentationViewController
//
//  Created by Chu Guimin on 16/9/8.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func firstAction(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "CustomPresentation", bundle: nil)
        let controller = storyBoard.instantiateViewControllerWithIdentifier("FirstAViewController") as! FirstAViewController
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func secondAction(sender: AnyObject) {
    
    }
    
    @IBAction func thirdAction(sender: AnyObject) {
    
    }
}
