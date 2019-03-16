//
//  ResponseModel+Extension.swift
//  TableViewTest
//
//  Created by 黄朔 on 2019/3/16.
//  Copyright © 2019 Prophet. All rights reserved.
//

import Foundation
import UIKit
import ZhuoZhuo

private var kCellHeight = "kCellHeight"
private var kCellImageViewHeight = "kCellImageViewHeight"
private var kAttrString = "kAttrString"

extension ResponseModel {
    
    open var cellHeight: CGFloat! {
        get {
            return objc_getAssociatedObject(self, &kCellHeight) as? CGFloat ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kCellHeight, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open var cellImageViewHeight: CGFloat! {
        get {
            return objc_getAssociatedObject(self, &kCellImageViewHeight) as? CGFloat ?? 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kCellImageViewHeight, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open var contextAttrString: NSMutableAttributedString? {
        get {
            return objc_getAssociatedObject(self, &kAttrString) as? NSMutableAttributedString
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kAttrString, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func contextTransform() {
        if context.count == 0 || clickInfoList.count == 0 {
            return
        }
        
        let attrStr = NSMutableAttributedString(string: context)
        attrStr.setAttributes([.font: UIFont.systemFont(ofSize: 17)], range: NSRange(location: 0, length: context.count))
        for clickInfo in clickInfoList {
            if let clickRange = context.range(of: clickInfo.targetString) {
                let nsRange = context.nsRange(from: clickRange)
                attrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: nsRange)
                if clickInfo.url.count > 0 {
                    attrStr.addAttribute(.link, value: clickInfo.url, range: nsRange)
                }
            }
        }
        
        contextAttrString = attrStr
    }
    
}
