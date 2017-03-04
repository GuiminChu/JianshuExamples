//
//  CTDisplayView.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CTDisplayView: UIView {
    
    var data: CoreTextData?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 获取绘图上下文
        let context = UIGraphicsGetCurrentContext()!
        
        // 翻转坐标系。对于底层的绘制引擎来说，屏幕的左下角是(0, 0)坐标。而对于上层的 UIKit 来说，左上角是(0, 0)坐标。
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        if data != nil {
            CTFrameDraw(data!.ctFrame, context)
        }
    }
}
