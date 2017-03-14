//
//  CTFrameParser.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class PictureRunInfo {
    
    var ascender: CGFloat
    var descender: CGFloat
    var width: CGFloat
    
    init(ascender: CGFloat, descender: CGFloat, width: CGFloat) {
        self.ascender = ascender
        self.descender = descender
        self.width = width
    }
}

// 用于生成最后绘制界面需要的 CTFrame 实例
class CTFrameParser: NSObject {
    
    static func parseString(content: String, config: CTFrameParserConfig) -> CoreTextData {
        let attributes = self.attributes(config: config)
        let contentString = NSAttributedString(string: content, attributes: attributes)
        
        // 创建 CTFramesetter 实例
        let framesetter = CTFramesetterCreateWithAttributedString(contentString)
        
        // 获取要绘制的区域的高度
        let restrictSize = CGSize(width: config.width, height: CGFloat.greatestFiniteMagnitude)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil)
        let textHeight = coreTextSize.height
        
        // 生成 CTFrame 实例
        let frame = self.creatFrame(framesetter: framesetter, config: config, height: textHeight)
        
        // 将生成的 CTFrame 实例和计算好的绘制高度保存到 CoreTextData 实例中
        let data = CoreTextData(ctFrame: frame, height: textHeight)
        
        // 返回 CoreTextData 实例
        return data
    }
    
    class func parse(content: NSAttributedString, config: CTFrameParserConfig) -> CoreTextData {
        // 创建 CTFramesetter 实例
        let framesetter = CTFramesetterCreateWithAttributedString(content)
        
        // 获取要绘制的区域的高度
        let restrictSize = CGSize(width: config.width, height: CGFloat.greatestFiniteMagnitude)
        let coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil)
        let textHeight = coreTextSize.height
        
        // 生成 CTFrame 实例
        let frame = self.creatFrame(framesetter: framesetter, config: config, height: textHeight)
        
        // 将生成的 CTFrame 实例和计算好的绘制高度保存到 CoreTextData 实例中
        let data = CoreTextData(ctFrame: frame, height: textHeight)
        
        // 返回 CoreTextData 实例
        return data
    }
    
    /// 创建矩形文字区域
    ///
    /// - Parameters:
    ///   - framesetter: framesetter 文字内容
    ///   - config: 配置信息
    ///   - height: 高度
    /// - Returns: 矩形文字区域
    class func creatFrame(framesetter: CTFramesetter, config: CTFrameParserConfig, height: CGFloat) -> CTFrame {
        let path = CGMutablePath()
        path.addRect(CGRect(x: 0, y: 0, width: config.width, height: height))
        
        return CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, nil)
    }
    
    
    /// 配置文字信息
    ///
    /// - Parameter config: 配置信息
    /// - Returns: 文字基本属性
    class func attributes(config: CTFrameParserConfig) -> [String: Any] {
        // 字体大小
        let fontSize = config.fontSize
        let uiFont = UIFont.systemFont(ofSize: fontSize)
        let ctFont = CTFontCreateWithName(uiFont.fontName as CFString?, fontSize, nil)
        // 字体颜色
        let textColor = config.textColor
        
        // 行间距
        var lineSpacing = config.lineSpace
        
        let settings = [
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .maximumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing),
            CTParagraphStyleSetting(spec: .minimumLineSpacing, valueSize: MemoryLayout<CGFloat>.size, value: &lineSpacing)
        ]
        let paragraphStyle = CTParagraphStyleCreate(settings, settings.count)
        
        // 封装
        let dict: [String: Any] = [
            NSForegroundColorAttributeName: textColor,
            NSFontAttributeName: ctFont,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        return dict
    }
    
    /// 解析模板文件
    class func parseTemplateFile(path: String, config: CTFrameParserConfig) -> CoreTextData {
        var imageArray = [CoreTextImageData]()
        var linkArray  = [CoreTextLinkData]()
        
        let content = self.loadTemplateFile(path: path, config: config, imageArray: &imageArray, linkArray: &linkArray)
        
        let coreTextData = self.parse(content: content, config: config)
        
        coreTextData.imageArray = imageArray
        coreTextData.linkArray = linkArray
        
        return coreTextData
    }
    
    /// 加载模板文件
    class func loadTemplateFile(path: String, config: CTFrameParserConfig, imageArray: inout [CoreTextImageData], linkArray: inout [CoreTextLinkData]) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: path, ofType: "json")!)
        if let data = try? Data(contentsOf: url) {
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let array = jsonObject as? [[String: String]] {
                for item in array {
                    let type = item["type"]
                    
                    if type == "txt" {
                        let subStr = self.parseAttributedCotnentFromDictionary(dict: item, config: config)
                        result.append(subStr)
                    }
                    
                    if type == "image" {
                        let imageData = CoreTextImageData()
                        imageData.name = item["name"]
                        imageData.imagePosition = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
                        imageArray.append(imageData)
                        
                        let subStr = self.parseImageAttributedCotnentFromDictionary(dict: item, config: config)
                        result.append(subStr)
                    }
                    
                    if type == "link" {
                        let startPosition = result.length
                        let subStr = self.parseAttributedCotnentFromDictionary(dict: item, config: config)
                        result.append(subStr)
                        
                        let linkData = CoreTextLinkData()
                        linkData.title = item["content"]
                        linkData.url   = item["url"]
                        linkData.range = NSMakeRange(startPosition, result.length - startPosition)
                        linkArray.append(linkData)
                    }
                }
            }
        }
        
        return result
    }

    /// 从字典中解析文字富文本信息
    ///
    /// - Parameters:
    ///   - dict: 文字属性字典
    ///   - config: 配置信息
    /// - Returns: 文字富文本
    class func parseAttributedCotnentFromDictionary(dict: [String: String], config: CTFrameParserConfig) -> NSAttributedString {
  
        var attributes = self.attributes(config: config)
        
        // 设置文字颜色
        if let colorValue = dict["color"] {
            attributes[NSForegroundColorAttributeName] = UIColor(hexString: colorValue)
        }
        
        // 设置文字大小
        if let sizeValue = dict["size"] {
            
            if let n = NumberFormatter().number(from: sizeValue) {
                
                if n.intValue > 0 {
                    attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: CGFloat(n))
                }
            }
        }
        
        // 文本
        let contentStr = dict["content"] ?? ""
        
        return NSAttributedString(string: contentStr, attributes: attributes)
    }
    
    /// 从字典中解析图片富文本信息
    ///
    /// - Parameters:
    ///   - dict: 文字属性字典
    ///   - config: 配置信息
    /// - Returns: 图片富文本
    class func parseImageAttributedCotnentFromDictionary(dict: [String: String], config: CTFrameParserConfig) -> NSAttributedString {
        var ascender: CGFloat = 0.0
        if let height = (dict["height"] as AnyObject).floatValue {
            ascender = CGFloat(height)
        }
        var width: CGFloat = 0.0
        if let w = (dict["width"] as AnyObject).floatValue {
            width = CGFloat(w)
        }
        let pic = PictureRunInfo(ascender: ascender, descender: 0.0, width: width)
        
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1, dealloc: { refCon in
            print("RunDelegate dealloc!")
        }, getAscent: { (refCon) -> CGFloat in
            let pictureRunInfo = unsafeBitCast(refCon, to: PictureRunInfo.self)
            return pictureRunInfo.ascender
        }, getDescent: { (refCon) -> CGFloat in
            return 0
        }, getWidth: { (refCon) -> CGFloat in
            
            let pictureRunInfo = unsafeBitCast(refCon, to: PictureRunInfo.self)
            return pictureRunInfo.width
        })
        
        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passRetained(pic).toOpaque())
        
        // 创建 RunDelegate, delegate决定留给图片的空间大小
        let runDelegate = CTRunDelegateCreate(&callbacks, selfPtr)
        
        let attributes : Dictionary = self.attributes(config: config)
        // 创建一个空白的占位符
        let space = NSMutableAttributedString(string: " ", attributes: attributes)
        
        CFAttributedStringSetAttribute(space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegate)
        return space
    }
}
