//
//  CTFrameParser.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CTFrameParser: NSObject {
    
    static func parse(content: NSAttributedString, config: CTFrameParserConfig) -> CoreTextData {
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
                        var imageData = CoreTextImageData()
                        imageData.name = item["name"]
                        imageData.imagePosition = CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0)
                        imageArray.append(imageData)
                        
                        let subStr = self.parseAttributedCotnentFromDictionary(dict: item, config: config)
                        result.append(subStr)
                    }
                }
            }
        }
        
        return result
    }

    /// 从字典中解析富文本信息
    ///
    /// - Parameters:
    ///   - dict: 文字属性字典
    ///   - config: 配置信息
    /// - Returns: 富文本
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
}
