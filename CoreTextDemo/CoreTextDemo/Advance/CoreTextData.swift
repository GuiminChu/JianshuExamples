//
//  CoreTextData.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

struct CoreTextImageData {
    var name: String!           // 图片名称
    var imagePosition: CGRect!  // 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
}

struct CoreTextLinkData {
    var title:String!   // 文字
    var range:NSRange!  // 文字区间
    var url:String?     // 超链
}

class CoreTextData: NSObject {
    
    var ctFrame: CTFrame
    var height: CGFloat
    var imageArray: [CoreTextImageData]?
    var linkArray: [CoreTextLinkData]?
    
    init(ctFrame: CTFrame, height: CGFloat) {
        self.ctFrame = ctFrame
        self.height = height
    }
    
    private func fillImagePosition(imageArray: [CoreTextImageData]) {
        if imageArray.count == 0 {
            return
        }
        
        let lines = CTFrameGetLines(ctFrame) as Array
        var originsArray = [CGPoint](repeating: CGPoint.zero, count:lines.count)
        // 把 CTFrame 里每一行的初始坐标写到数组里
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), &originsArray)
        
        var imgIndex : Int = 0
        var imageData: CoreTextImageData? = imageArray[0]
        
        for index in 0..<lines.count {
            
            guard imageData != nil else {
                    return
            }
            
            let line = lines[index] as! CTLine
            let runObjArray = CTLineGetGlyphRuns(line) as Array
            
            for runObj in runObjArray {
                let run = runObj as! CTRun
                let runAttributes = CTRunGetAttributes(run) as NSDictionary
                let delegate = runAttributes.value(forKey: kCTRunDelegateAttributeName as String) as! CTRunDelegate?
                
                if delegate == nil {
                    continue
                }
                
//                let dic = CTRunDelegateGetRefCon(delegate!)
                
//                let metaDict = unsafeBitCast(dic, to: NSDictionary.self)
                
                
                
                var runBounds: CGRect
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                runBounds = CGRect()
                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                runBounds.size.height = ascent + descent
                
                let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                runBounds.origin.x = originsArray[index].x + xOffset
                runBounds.origin.y = originsArray[index].y
                runBounds.origin.y = descent
                
                let pathRef = CTFrameGetPath(ctFrame)
                
                let colRect = pathRef.boundingBox
                
                let delegateBounds = runBounds.offsetBy(dx: colRect.origin.x, dy: colRect.origin.y)
                
                imageData!.imagePosition = delegateBounds
                
                imgIndex += 1
                if imgIndex == self.imageArray!.count {
                    imageData = nil
                    break
                } else {
                    imageData = self.imageArray![imgIndex]
                }
            }
        }
    }
}
