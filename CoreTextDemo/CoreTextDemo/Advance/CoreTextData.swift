//
//  CoreTextData.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CoreTextImageData {
    var name: String!               // 图片名称
    var imagePosition = CGRect.zero // 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
}

struct CoreTextLinkData {
    var title: String!   // 文字
    var range: NSRange!  // 文字区间
    var url: String?     // 超链
}

class CoreTextData: NSObject {
    
    var ctFrame: CTFrame
    var height: CGFloat
    var imageArray: [CoreTextImageData] = [CoreTextImageData]() {

        willSet {
            fillImagePosition(imageArray: newValue)
        }
        
    }
    var linkArray: [CoreTextLinkData]?
    
    init(ctFrame: CTFrame, height: CGFloat) {
        self.ctFrame = ctFrame
        self.height = height
    }
    
    private func fillImagePosition1(imageArray: [CoreTextImageData]) {
        
        if imageArray.count == 0 {
            return
        }
        let ctRunRectArray = CTFrameParserCAPI.findImagePosition(ctFrame) as! [NSValue]
        
        for (index, imageData) in imageArray.enumerated() {
            imageData.imagePosition = ctRunRectArray[index].cgRectValue
        }
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
                let delegate = runAttributes.value(forKey: kCTRunDelegateAttributeName as String)
                
                if delegate == nil {
                    continue
                }
                
                var runBounds = CGRect()
                var ascent: CGFloat = 0
                var descent: CGFloat = 0
                
                runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
                runBounds.size.height = ascent + descent
                
                let xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
                runBounds.origin.x = originsArray[index].x + xOffset
                runBounds.origin.y = originsArray[index].y
                runBounds.origin.y -= descent
                
                let path = CTFrameGetPath(ctFrame)
                
                let colRect = path.boundingBox
                
                let delegateBounds = runBounds.offsetBy(dx: colRect.origin.x, dy: colRect.origin.y)
                
                imageData!.imagePosition = delegateBounds
                
                imgIndex += 1
                if imgIndex == imageArray.count {
                    imageData = nil
                    break
                } else {
                    imageData = imageArray[imgIndex]
                }
            }
        }
    }
    

    
    private func fillImagePosition3(imageArray: [CoreTextImageData]) {
        if imageArray.count == 0 {
            return
        }
        
        let lines:NSArray = CTFrameGetLines(ctFrame);
        let lineCount = lines.count;
        let lineOrigins: UnsafeMutablePointer<CGPoint> = UnsafeMutablePointer<CGPoint>.allocate(capacity: lineCount);
        CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
        
        var imageIndex = 0;
        

        var imageData:CoreTextImageData? = imageArray[0];
        for i in 0..<lineCount {
            if imageData == nil {
                return;
            }
            
            let line = lines[i] as! CTLine;
            let runObjArray:NSArray = CTLineGetGlyphRuns(line);
            
            for runObj in runObjArray {
                let run: CTRun = runObj as! CTRun;
                
                let runAttributed: NSDictionary = CTRunGetAttributes(run);
                
                if let _ = (runAttributed[kCTRunDelegateAttributeName as String]) {
                    
                    var runBounds = CGRect();
                    var ascent = CGFloat();
                    var descent = CGFloat();
                    
                    runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil));
                    runBounds.size.height = ascent + descent;
                    
                    let xOffSet = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil);
                    runBounds.origin.x = lineOrigins[i].x + xOffSet;
                    runBounds.origin.y = lineOrigins[i].y;
                    runBounds.origin.y -= descent;
                    
                    let pathRef = CTFrameGetPath(ctFrame);
                    let colRect = pathRef.boundingBox
                    let delegateBounds = runBounds.offsetBy(dx: colRect.origin.x, dy: colRect.origin.y)
                    imageData?.imagePosition = delegateBounds;
                    imageIndex += 1;
                    
                    if imageIndex == imageArray.count {
                        imageData = nil;
                        break;
                    } else {
                        imageData = imageArray[imageIndex];
                    }
                    
                } else {
                    continue;
                }
                
                
            }
        }
    }

}
