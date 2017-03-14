//
//  CTFrameParserConfig.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

// 用于配置绘制的参数，例如：文字颜色，大小，行间距等。
struct CTFrameParserConfig {
    
    var width: CGFloat = 300.0
    var fontSize: CGFloat = 16.0
    var lineSpace = 8.0
    var textColor = UIColor.rgb(108, 108, 108)
}
