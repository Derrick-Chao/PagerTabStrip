//
//  IndicatorInfo.swift
//  PagerTabStripFramework
//
//  Created by DerrickChao on 2021/7/30.
//

import Foundation
import UIKit

public struct IndicatorInfo {
    public var title: String?
    public var image: UIImage?
    public var highlightImage: UIImage?
    
    public init(title: String?) {
        self.title = title
    }
    
    public init(image: UIImage?, highlightImage: UIImage? = nil) {
        self.image = image
        self.highlightImage = highlightImage
    }
}
