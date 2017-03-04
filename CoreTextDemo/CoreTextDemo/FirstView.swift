//
//  FirstView.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/2/28.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit

class FirstView: UIView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 1.获取绘图上下文
        let context = UIGraphicsGetCurrentContext()!
        
        // 2.翻转当前的坐标系
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // 3.创建需要绘制的文字
        let mutableAttributeString = NSMutableAttributedString(string: "If you do not learn to think when you are young, you may never learn.Talents come from diligence, and knowledge is gained by accumulation.")
        
        // 4.设置相应文字内容属性
        mutableAttributeString.addAttribute(NSFontAttributeName, value:UIFont.systemFont(ofSize: 20), range: NSMakeRange(0, 48))
        mutableAttributeString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSMakeRange(0, 48))
        
        // 或者使用CoreText API：
//        mutableAttributeString.addAttribute(kCTFontAttributeName as String, value: CTFontCreateWithName("Helvetica Neue", 20, nil), range: NSMakeRange(47, 22))
//        mutableAttributeString.addAttribute(kCTForegroundColorAttributeName as String, value: UIColor.blue, range: NSMakeRange(47, 22))
        
        // 设置行间距
        var lineSpacing: CGFloat = 5
        var lineSpacingMax: CGFloat = 10
        var lineSpacingMin: CGFloat = 2
        
        let setting = [CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
                       CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacingMax),
                       CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacingMin)
        ]
        let paragraphStyle = CTParagraphStyleCreate(setting, 3)
        mutableAttributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, mutableAttributeString.length))
        
        // 5. 初始化路径
        let mutablePath = CGPath(rect: self.bounds, transform: nil)
        
        // 6.根据 AttributedString 初始化Framesetter
        let frameSetter = CTFramesetterCreateWithAttributedString(mutableAttributeString)
        
        // 7.绘制 Frame
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, mutableAttributeString.length), mutablePath, nil)
        CTFrameDraw(ctFrame, context)  
    }  
}
