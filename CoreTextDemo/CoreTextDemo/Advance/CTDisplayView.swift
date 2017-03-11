//
//  CTDisplayView.swift
//  CoreTextDemo
//
//  Created by Chu Guimin on 17/3/3.
//  Copyright © 2017年 cgm. All rights reserved.
//

import UIKit

class CTDisplayView: UIView {
    
    typealias CoreTextImageTapAction = (_ displayView: CTDisplayView, _ imageData: CoreTextImageData) -> ()
    
    var data: CoreTextData?
    var imageTapAction: CoreTextImageTapAction?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupEvents()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupEvents()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 获取绘图上下文
        let context = UIGraphicsGetCurrentContext()!
        
        // 翻转坐标系。对于底层的绘制引擎来说，屏幕的左下角是(0, 0)坐标。而对于上层的 UIKit 来说，左上角是(0, 0)坐标。
        context.textMatrix = CGAffineTransform.identity
        context.translateBy(x: 0, y: self.bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        if data != nil {
            CTFrameDraw(data!.ctFrame, context)
            
            for imageData in data!.imageArray {
                let image = UIImage(named: imageData.name)
                
                if let image = image {
                    context.draw(image.cgImage!, in: imageData.imagePosition)
                }
            }
        }
    }
    
    private func setupEvents() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userTapGestureDetected(recognizer:)))
        self.addGestureRecognizer(tapGestureRecognizer)
        self.isUserInteractionEnabled = true
    }
    
    func userTapGestureDetected(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: self)
        print("point\(point)")
        if let imageArray = data?.imageArray {
            for imageData in imageArray {
                // 翻转坐标系，因为 imageData 中的坐标是 CoreText 的坐标系
                let imageRect = imageData.imagePosition
                var imagePosition = imageRect.origin
                imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height
                let rect = CGRect(x: imagePosition.x, y: imagePosition.y, width: imageRect.size.width, height: imageRect.size.height)
                if rect.contains(point) {
                    print("\(imageData.name)")
                    
                    imageTapAction?(self, imageData)
                    
                    break
                }
            }
        }
        
        if let d = data {
            let linkData = CoreTextUtils.touchLink(inView: self, atPoint: point, data: d)
            if linkData != nil {
                print(linkData!.url)
            }
        }
    }
    
    public func tapCoreTextImage(_ tapAction: CoreTextImageTapAction?) {
        imageTapAction = tapAction
    }
}
