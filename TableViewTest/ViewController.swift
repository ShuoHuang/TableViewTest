//
//  ViewController.swift
//  TableViewTest
//
//  Created by 黄朔 on 2019/3/16.
//  Copyright © 2019 Prophet. All rights reserved.
//

import UIKit
import ZhuoZhuo

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [ResponseModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var imageSizeChanged: ((_ data: ResponseModel, _ newImage: UIImage) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
        imageSizeChanged = { [weak self] (model, newImage) in
            objc_sync_enter(self as Any)
            DispatchQueue.global().async {
                print("----更新： " + model.imageUrl)
                if let index = self?.dataSource.index(of: model) {
                    
                    model.imageSizeInfo.width = Int(newImage.size.width)
                    model.imageSizeInfo.height = Int(newImage.size.height)
                    
                    model.cellHeight = TestCell.cellHeight(with: model)
                    
                    DispatchQueue.main.async {
                        self?.tableView.beginUpdates()
                        self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                        self?.tableView.endUpdates()
                    }
                }
            }
            objc_sync_exit(self as Any)
        }
        
        loadData()
    }
    
    /// 加载数据，并预先计算cell高度
    /// 当图片不在本地时，以ResponseModel的图片尺寸为准，当存在时，以真实图片的尺寸为准
    func loadData() {
        // 异步处理数据，这里可以给用户转个圈
        DispatchQueue.global().async {
            let ds = RdTestGetResource__NotAllowedInMainThread()
            for model in ds ?? [] {
                if let image = HSImageCache.shared.imageInDisk(with: model.imageUrl) {
                    model.imageSizeInfo.width = Int(image.size.width)
                    model.imageSizeInfo.height = Int(image.size.height)
                }
                model.cellHeight = TestCell.cellHeight(with: model)
                
                model.contextTransform()
            }
            DispatchQueue.main.async { [weak self] in
                self?.dataSource = ds!
            }
        }
    }
    
}

/// ---- UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestCell", for: indexPath) as! TestCell
        cell.data = dataSource[indexPath.row]
        cell.imageSizeChanged = imageSizeChanged
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.row].cellHeight
    }
}

/// ---- TestCell
class TestCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var contextView: UITextView!
    @IBOutlet weak var cellImageViewHeight: NSLayoutConstraint!
    // 点击回调
    var clickCallback: ((_ url: String) -> Void)?
    
    var imageSizeChanged: ((_ data: ResponseModel, _ newImage: UIImage) -> Void)?
    
    var data: ResponseModel! {
        didSet {
            titleLabel.text = data.title
            if let string = data.contextAttrString {
                contextView.attributedText = string
            } else {
                contextView.text = data.context
            }
            cellImageViewHeight.constant = data.cellImageViewHeight
            cellImageView.image(with: data.imageUrl)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellImageView.imageChanged = { [weak self] (image, url) in
            if let callback = self?.imageSizeChanged, let data = self?.data, url == data.imageUrl {
                callback(data, image)
            }
        }
    }
    
    //    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    //        // 拦截请求
    //        return true
    //    }
}

/// TestCell高度计算扩展
extension TestCell {
    
    /// 根据数据计算Cell高度
    static func cellHeight(with data: ResponseModel) -> CGFloat {
        // 计算图片的高度
        let cellImageViewHeight: CGFloat = TestCell.cellImageViewHeight(with: data)
        data.cellImageViewHeight = cellImageViewHeight
        // 计算context文本的高度
        var contextHeight = 0
        if data.context.count > 0 {
            contextHeight = Int(data.context.height(with: 17, in: Float(UIScreen.main.bounds.size.width - (15 * 2))))
        }
        // 加上固定的titleLable和空白处高度，这里本应该出来空白处的问题，但是这里直接忽略了这个问题
        return cellImageViewHeight + CGFloat(contextHeight) + 49
    }
    
    /// 计算图片高度，宽度以屏幕宽度为准
    private static func cellImageViewHeight(with data: ResponseModel) -> CGFloat {
        let cellImageViewWidth = UIScreen.main.bounds.size.width - (15 * 2)
        
        // 计算图片的高度
        var cellImageViewHeight: CGFloat = 0
        if data.imageSizeInfo.width > 0 {
            cellImageViewHeight = CGFloat(cellImageViewWidth) * CGFloat(data.imageSizeInfo.height) / CGFloat(data.imageSizeInfo.width)
        }
        return cellImageViewHeight
    }
    
}

