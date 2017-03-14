//
//  CoreTextUtils.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/8.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

struct CoreTextUtils {
    
    static func touchLink(inView view: UIView, atPoint point: CGPoint, data: CoreTextData) -> CoreTextLinkData? {
        
        guard let linkArray = data.linkArray else {
            return nil
        }
        
        let textFrame = data.ctFrame
        let lines = CTFrameGetLines(textFrame) as Array
        
        // 获取每一行的 origin 坐标
        let origins = UnsafeMutablePointer<CGPoint>.allocate(capacity: lines.count)
        CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins)
        
        // 翻转坐标系
        let transform = CGAffineTransform(translationX: 0, y: view.bounds.size.height)
        transform.scaledBy(x: 1, y: -1)
        
        for i in 0..<lines.count {
            let linePoint = origins[i]
            
            let line: CTLine = lines[i] as! CTLine
            
            // 获取每一行的 CGRect 信息
            let flippedRect = getLineBounds(bounds: line, point: linePoint)
            let rect = flippedRect.applying(transform)
            
            print(rect)
            
            if rect.contains(point) {
                print("hh")
                // 将点击的坐标转换成相对于当前行的坐标
                let relativePoint = CGPoint(x: point.x - rect.minX, y: point.y - rect.minY)
                // 获得当前点击坐标对应的字符串偏移
                let index = CTLineGetStringIndexForPosition(line, relativePoint)
                
                // 判断这个偏移是否在我们的链接列表中
                return link(index: index, linkArray: linkArray)
            }
        }
        
        return nil
    }
    
    private static func getLineBounds(bounds: CTLine, point: CGPoint) -> CGRect {
        var ascent  = CGFloat()
        var descent = CGFloat()
        var leading = CGFloat()
        
        let width = CGFloat(CTLineGetTypographicBounds(bounds, &ascent, &descent, &leading))
        let height = ascent + descent
        
        return CGRect(x: point.x, y: point.y - descent, width: width, height: height)
    }
    
    static func link(index: CFIndex, linkArray: [CoreTextLinkData]) -> CoreTextLinkData? {
        for coreTextLinkData in linkArray {
            if NSLocationInRange(index, coreTextLinkData.range) {
                return coreTextLinkData
            }
        }
        return nil
    }
}
