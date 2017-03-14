//
//  MixViewController.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/14.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class MixViewController: UIViewController {
    
    @IBOutlet weak var displayView: CTDisplayView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    let str = " 对于上面的例子，我们给 CTFrameParser 增加了一个将 NSString 转换为 CoreTextData 的方法。但这样的实现方式有很多局限性，因为整个内容虽然可以定制字体大小，颜色，行高等信息，但是却不能支持定制内容中的某一部分。例如，如果我们只想让内容的前三个字显示成红色，而其它文字显示成黑色，那么就办不到了。\n\n解决的办法很简单，我们让`CTFrameParser`支持接受NSAttributeString 作为参数，然后在 NSAttributeString 中设置好我们想要的信息。"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        demo1()
    }

    func demo0() {
        let config = CTFrameParserConfig()
        
        let attrs = CTFrameParser.attributes(config: config)
        
        let attrString = NSMutableAttributedString(string: str, attributes: attrs)
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(location: 0, length: 7))
        
        let data = CTFrameParser.parse(content: attrString, config: config)
        
        displayView.data = data
    }
    
    func demo1() {
        let config = CTFrameParserConfig()
        let data = CTFrameParser.parseTemplateFile(path: "content", config: config)
        
        viewHeight.constant = data.height
        
        displayView.data = data
        displayView.tapCoreTextImage { (displayView, imageData) in
            
        }
    }

}
