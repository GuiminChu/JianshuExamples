//
//  CustomPresentationController.swift
//  CustomPresentationViewController
//
//  Created by Chu Guimin on 16/9/8.
//  Copyright © 2016年 Chu Guimin. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {

    override func presentationTransitionWillBegin() {
        print("willBegin")
        
        
        
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ (context) in
            
            
            }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        print("didEnd")
    }
    
    override func dismissalTransitionWillBegin() {
        
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        
    }
}
