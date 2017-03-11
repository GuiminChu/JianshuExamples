//
//  UILabelViewController.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/1.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class UILabelViewController: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!

    let contentString = "作者写在书后：时间是2003年或2004年，季节可能是夏末也可能是秋初。\n详细的时间和季节记不清了，只记得我一个人在午后的北京街头闲逛，碰到一群大学生，约二十个，男女都有，在路旁树荫下一米高左右的矮墙上坐成一列。\n他们悠闲地晃动双腿，谈笑声此起彼落。我从他们面前走过，不禁想起过去也曾拥有类似的青春。\n………"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建富文本字符串
        let attributedText = NSMutableAttributedString(string: contentString)
        
        // 图片附件
        let imageAttachment = NSTextAttachment()
        let image = UIImage(named: "nuannuan0.jpg")
        imageAttachment.image = image
        
        // 设置图片显示的宽度和 UILabel 的宽度一致
        let imageWidth = contentLabel.frame.width
        let imageHeight = image!.size.height / image!.size.width * imageWidth
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        
        // 将带图片附件的富文本字符串插入到指定位置
        attributedText.insert(NSAttributedString(attachment: imageAttachment), at: 7)

        
        contentLabel.attributedText = attributedText
    }
}
