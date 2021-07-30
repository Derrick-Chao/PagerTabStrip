//
//  ButtonBarView.swift
//  PagerTabStripFramework
//
//  Created by DerrickChao on 2021/7/30.
//

import UIKit

public class ButtonBarViewSettings {
    static let minimumHeight: CGFloat = 50.0
    public init() {}
    
    public var updateSettings: (() -> Void)?
    public var buttonBarBackgroundColor: UIColor = .white {
        didSet {
            updateSettings?()
        }
    }
    public var barInteritemSpacing: CGFloat = 12.0 {
        didSet {
            updateSettings?()
        }
    }
    public var viewHeight: CGFloat = 70.0 {
        didSet {
            if viewHeight < ButtonBarViewSettings.minimumHeight {
                viewHeight = ButtonBarViewSettings.minimumHeight
            }
            updateSettings?()
        }
    }
    public var itemTextFont: UIFont = UIFont.systemFont(ofSize: 16.0, weight: .regular) {
        didSet {
            updateSettings?()
        }
    }
    public var itemLeftRightPadding: CGFloat = 20.0 {
        didSet {
            updateSettings?()
        }
    }
    public var itemBorderColor: UIColor = .lightGray {
        didSet {
            updateSettings?()
        }
    }
    public var itemUnselectedBackgroundColor: UIColor = .white {
        didSet {
            updateSettings?()
        }
    }
    public var itemSelectedBackgroundColor: UIColor = .black {
        didSet {
            updateSettings?()
        }
    }
    public var itemSelectedTextColor: UIColor = .white {
        didSet {
            updateSettings?()
        }
    }
    public var itemUnselectedTextColor: UIColor = .black {
        didSet {
            updateSettings?()
        }
    }
    public var itemShadowColor: UIColor = .black {
        didSet {
            updateSettings?()
        }
    }
    public var barLeftRightInset: CGFloat = 12.0 {
        didSet {
            updateSettings?()
        }
    }
}

class ButtonBarView: UICollectionView {
    // MARK:- Outlets
    
    // MARK:- Public property
    
    // MARK:- Private property
    
    // MARK:- Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initView()
    }
    
    // MARK:- Layouts
    private func initView() {
     
        let cellNib = UINib(nibName: "ButtonBarCell", bundle: .module)
        register(cellNib, forCellWithReuseIdentifier: "ButtonBarCell")
        showsHorizontalScrollIndicator = false
    }
    
    // MARK:- Public methods
    
    // MARK:- Private methods
    
    // MARK:- Actions

}

