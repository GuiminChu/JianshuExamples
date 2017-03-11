//
//  CTSimpleDisplayView.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/2.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CTSimpleDisplayView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 获取绘图上下文
        let context = UIGraphicsGetCurrentContext()!
        
        // 翻转坐标系。对于底层的绘制引擎来说，屏幕的左下角是(0, 0)坐标。而对于上层的 UIKit 来说，左上角是(0, 0)坐标。
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // 初始化绘制路径
        let path = CGMutablePath()
        path.addRect(self.bounds)
        
        // 初始化需要绘制的文字
        let attString = NSAttributedString(string: "Hello World!")
        
        // 初始化 CTFramesetter
        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        
        // 创建 CTFrame。可以把 CTFrame 理解成画布，画布的范围由 CGPath 决定。
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, nil)
        
        // 绘制
        CTFrameDraw(frame, context)
    }
}
