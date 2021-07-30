//
//  ButtonBarCell.swift
//  PagerTabStripFramework
//
//  Created by DerrickChao on 2021/7/30.
//

import UIKit

class ButtonBarCell: UICollectionViewCell {
    // MARK:- Outlets
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK:- Public property
    
    // MARK:- Private property
    private var isDisplayingTab: Bool = false {
        didSet {
            configureLayout()
        }
    }
    
    // MARK:- Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 調整 Shadow 的大小
        let rect = CGRect(x: 5.0, y: 5.0, width: bounds.width - 10.0, height: bounds.height - 10.0)
        layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: 8.0).cgPath
    }
    
    // MARK:- Layouts
    private func initView() {
                
        baseView.layer.borderWidth = 1.0
        baseView.layer.cornerRadius = 8.0
        
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
        
        layer.masksToBounds = false
//        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowRadius = 8.0
    }
    
    // MARK:- Public methods
    func setLayoutProperties(settings: ButtonBarViewSettings, isDisplayingTab: Bool) {
        
        self.isDisplayingTab = isDisplayingTab
        titleLabel.textColor = isDisplayingTab ? settings.itemSelectedTextColor : settings.itemUnselectedTextColor
        titleLabel.font = settings.itemTextFont
        baseView.layer.borderColor = settings.itemBorderColor.cgColor
        baseView.backgroundColor = isDisplayingTab ? settings.itemSelectedBackgroundColor : settings.itemUnselectedBackgroundColor
        layer.shadowColor = settings.itemShadowColor.cgColor
    }
    
    func setTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    // MARK:- Private methods
    private func configureLayout() {
        
        if isDisplayingTab {
            
            layer.shadowOpacity = 0.5
            baseView.layer.borderWidth = 0.0
        } else {
            
            layer.shadowOpacity = 0.0
            baseView.layer.borderWidth = 1.0
        }
    }
    
    // MARK:- Actions

}
