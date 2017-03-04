//
//  FirstViewTwo.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/2/28.
//  Copyright © 2017年 e-inv. All rights reserved.
//

import UIKit

private let ImageName: String = "boy"
private let UrlImageName: String = "http://img3.3lian.com/2013/c2/64/d/65.jpg"

class FirstViewTwo: UIView {
    
    var image: UIImage?
    var imageFrameArr: NSMutableArray = NSMutableArray()
    var ctFrame: CTFrame?
    
    var attrString = ""
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //1 获取上下文
        let context = UIGraphicsGetCurrentContext()!
        
        //2 转换坐标
        convertCoordinateSystem(context: context)
        
        //3 绘制区域
        let mutablePath = UIBezierPath(rect: rect)
        
        
        // 处理图文
        let tuples = handleContentString(attrString)
        
        print(tuples)
        
        //4 创建需要绘制的文字并设置相应属性
        let mutableAttributeString = settingTextAndAttribute(attrString: tuples.0)
        
        // insertIndex 记录需要插入图片的原始位置，插入一张图片后(图片占一个字符)原始位置向右偏移一位才是真实位置
        for (offset, insertIndex) in tuples.1.enumerated() {
            
            addCTRunDelegateWith(imageStr: UrlImageName, indentifier: UrlImageName, insertIndex: insertIndex + offset, attribute: mutableAttributeString)

        }
        
        
        
        //5 为本地图片设置CTRunDelegate，添加占位符
//        addCTRunDelegateWith(imageStr: ImageName, indentifier: ImageName, insertIndex: 19, attribute: mutableAttributeString)
        
        //6 为网络图片设置CTRunDelegate
//        addCTRunDelegateWith(imageStr: UrlImageName, indentifier: UrlImageName, insertIndex: 35, attribute: mutableAttributeString)
        
        //7 使用mutableAttributeString生成framesetter，使用framesetter生成CTFrame
        let framesetter = CTFramesetterCreateWithAttributedString(mutableAttributeString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, mutableAttributeString.length), mutablePath.cgPath, nil)
        ctFrame = frame
        
        //8 绘制除图片以外的部分
        CTFrameDraw(frame, context)
        
        //9 处理绘制图片逻辑
        searchImagePosition(frame: frame, context: context)
    }
    
    func convertCoordinateSystem(context: CGContext) {
        
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
    }
    
    func settingTextAndAttribute(attrString: String) -> NSMutableAttributedString {
        
        let mutableAttributeString = NSMutableAttributedString(string: attrString)
        
        mutableAttributeString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 20), range: NSMakeRange(0, mutableAttributeString.length))
        
//        mutableAttributeString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 25),
//                                              NSForegroundColorAttributeName:UIColor.red ], range: NSMakeRange(0, 33))
//        mutableAttributeString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 15),NSUnderlineStyleAttributeName: 1], range: NSMakeRange(33,36))
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        mutableAttributeString.addAttributes([NSParagraphStyleAttributeName:style], range: NSMakeRange(0, mutableAttributeString.length))
        return mutableAttributeString
    }
    
    func addCTRunDelegateWith(imageStr: String, indentifier: String, insertIndex: Int, attribute: NSMutableAttributedString) {
        
        var imageName = imageStr
        
        var imageCallback = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { refCon in
            print("RunDelegate dealloc!")
        }, getAscent: { (refCon) -> CGFloat in
            return 100
        }, getDescent: { (refCon) -> CGFloat in
            return 0
        }, getWidth: { (refCon) -> CGFloat in
            return 300
        })
        
        //1:设置CTRun的代理,为图片设置CTRunDelegate,delegate决定留给图片的空间大小
        // 创建 RunDelegate, 传入 imageCallback 中图片数据
        let runDelegate = CTRunDelegateCreate(&imageCallback, &imageName)
        
        //2 为每个图片创建一个空的string占位
        let imageAttributedString = NSMutableAttributedString(string: " ")
        imageAttributedString.addAttribute(kCTRunDelegateAttributeName as String, value: runDelegate!, range: NSMakeRange(0, 1))
        
        //3:添加属性，在CTRun中可以识别出这个字符是图片
        imageAttributedString.addAttribute(indentifier, value: imageName, range: NSMakeRange(0, 1))
        //4:在index处插入图片
        attribute.insert(imageAttributedString, at: insertIndex)
    }
    
    func searchImagePosition(frame: CTFrame, context: CGContext) {
        
        let lines = CTFrameGetLines(frame) as Array
        
        var originsArray = [CGPoint](repeating: CGPoint.zero, count:lines.count)
        //把frame里每一行的初始坐标写到数组里
        CTFrameGetLineOrigins(frame,CFRangeMake(0, 0),&originsArray)
        
        //遍历每一行CTLine
        for i in 0..<lines.count {
            let line = lines[i]
            var lineAscent = CGFloat(),lineDescent = CGFloat(),lineLeading = CGFloat()
            //该函数除了会设置好ascent,descent,leading之外，还会返回当前行的宽度。
            CTLineGetTypographicBounds(line as! CTLine, &lineAscent, &lineDescent, &lineLeading)
            
            //获取每行中CTRun的个数
            let runs = CTLineGetGlyphRuns(line as! CTLine) as NSArray
            
            //遍历CTRun找出图片所在的CTRun并进行绘制,每一行可能有多个
            for j in 0..<runs.count {
                var runAscent = CGFloat(), runDescent = CGFloat()
                // 获取该行的初始坐标
                let lineOrigin = originsArray[i]
                // 获取当前的 CTRun
                let run = runs[j]
                // 获取 CTRun 中的属性集
                let attributes = CTRunGetAttributes(run as! CTRun) as NSDictionary
                // 获取 CTRun 的宽度
                let width = CGFloat(CTRunGetTypographicBounds(run as! CTRun, CFRangeMake(0,0), &runAscent, &runDescent, nil))
                
                // 开始计算该CTRun的frame吧,通过CTRunGetTypographicBounds取得宽，ascent和descent
                let runRect = CGRect(x: lineOrigin.x + CTLineGetOffsetForStringIndex(line as! CTLine, CTRunGetStringRange(run as! CTRun).location, nil), y: lineOrigin.y - runDescent, width: width, height: runAscent + runDescent)
                // 判断CTRunDelegateRef是否存在
                let delegate = attributes.value(forKey: kCTRunDelegateAttributeName as String)
                if  delegate != nil {
                    showImageToContextWith(runRect: runRect, context: context, attributes: attributes)
                }
            }  
        }  
    }
    
    func showImageToContextWith(runRect: CGRect, context: CGContext, attributes: NSDictionary) {
        
        let image: UIImage?
        let imageDrawRect = CGRect(x: runRect.origin.x, y: runRect.origin.y, width: 100.0, height: 100.0)
        
        imageFrameArr.add(NSValue.init(cgRect: imageDrawRect))
        
        if let imageName = attributes.object(forKey: ImageName) as? String {
            // 直接绘制本地图片
            image = UIImage(named:imageName as String)
            context.draw(image!.cgImage!, in: imageDrawRect)
        } else if let urlImageName = attributes.object(forKey: UrlImageName) as? String {
            // 网络图片的绘制也很简单如果没有下载,使用图占位，然后去下载，下载好了重绘就OK了.
            if self.image == nil {
                image = UIImage(named:"boy") //灰色图片占位
                if let url = URL(string: urlImageName) {
                    let request = URLRequest(url: url)
                    
                    URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                        if let data = data {
                            DispatchQueue.main.sync {
                                self.image = UIImage(data: data)
                                self.setNeedsDisplay()  // 下载完成后重绘
                            }
                        }
                    }).resume()
                }
            } else {
                image = self.image
            }
            
            context.draw((image?.cgImage)!, in: imageDrawRect)
        }
    }
    
    func handleContentString(_ str: String) -> (String, [Int]) {
        
        var indexArray = [Int]()
        guard let _ = str.range(of: "<图片") else {
            return (str, indexArray)
        }
        
        // 删除文本中的换行符"\r" (注：\r不占用字符)
        var result = str.replacingOccurrences(of: "\r", with: "")
        
        while let range = result.range(of: "<图片") {
            indexArray.append(result.characters.distance(from: result.startIndex, to: range.lowerBound))
            
            // 从 "<图片1" 后面的字符串中检索 ">"
            let r = Range(range.lowerBound..<result.endIndex)
            // <图片1> 右侧 ">" 的 Range
            let rightRange = result.range(of: ">", options: NSString.CompareOptions.caseInsensitive, range: r)
            // <图片1> 的 Range
            let picRange = Range(range.lowerBound..<rightRange!.upperBound)
            result = result.replacingCharacters(in: picRange, with: "\n\n")
        }
        
        return (result, indexArray)
    }
}
