//
//  UIImageView+Extension.swift
//  TableViewTest
//
//  Created by 黄朔 on 2019/3/16.
//  Copyright © 2019 Prophet. All rights reserved.
//

import UIKit

private var kImageUrl = "kImageUrl"
private var kImageChanged = "kImageChanged"

public typealias ImageSizeChanged = (_ image: UIImage, _ url: String) -> Void

extension UIImageView {
    
    open var imageUrl: String! {
        get {
            return objc_getAssociatedObject(self, &kImageUrl) as? String ?? ""
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kImageUrl, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    open var imageChanged: ImageSizeChanged? {
        get {
            return objc_getAssociatedObject(self, &kImageChanged) as? ImageSizeChanged
        }
        set(newValue) {
            objc_setAssociatedObject(self, &kImageChanged, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    /// 用Url加载图片
    func image(with imageUrl: String) {
        if imageUrl.count == 0 {
            self.imageUrl = ""
            return
        }
        self.imageUrl = imageUrl
        
        if let image = HSImageCache.shared.image(with: imageUrl) {
            self.image = image
            checkImageSize()
        } else {
            HSImageCache.shared.subscribImage(with: imageUrl) { [weak self] (image, url) in
                if url == self?.imageUrl {
                    self?.image = image
                    self?.checkImageSize()
                }
            }
        }
    }
    
    /// 检查图片与view的宽高比是否相近
    private func checkImageSize() {
        // 为了获取当前控件真实尺寸
        superview?.layoutIfNeeded()
        
        if let image = self.image,
            abs((image.size.width / image.size.height) - (bounds.size.width / bounds.size.height)) > 0.1,
            let callback = imageChanged {
            
            callback(image, imageUrl)
        }
    }
    
}
