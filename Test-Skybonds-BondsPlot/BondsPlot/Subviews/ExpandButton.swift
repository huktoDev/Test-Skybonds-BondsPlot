//
//  ExpandButton.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

class ExpandButton: StyledPlotButton {
    
    struct ViewAssets {
        let fullScreenIcon: UIImage
    }
    
    private var _viewAssets: ViewAssets?
    internal var viewAssets: ViewAssets {
        get {
            guard let viewAssets = _viewAssets else {
                preconditionFailure("<Error> ViewAssets must be Injected before View using")
            }
            return viewAssets
        }
        set (newViewAssets) {
            _viewAssets = newViewAssets
            
            self.setImage(viewAssets.fullScreenIcon, for: .normal)
            self.setImage(viewAssets.fullScreenIcon, for: .highlighted)
        }
    }
    
    private let viewLayout = ViewLayout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    private func initialize() {
        
        self.tintColor = .black
    }
}

// MARK: - View Layout

extension ExpandButton {
    
    override internal func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        viewLayout.getImageRect(forContent: contentRect)
    }
    
    override internal var intrinsicContentSize: CGSize {
        
        return CGSize(
            width: viewLayout.minWidth,
            height: viewLayout.minHeight
        )
    }
}

private extension ExpandButton {
    
    struct ViewLayout {
        
        let minHeight: CGFloat
        let minWidth: CGFloat
        
        init() {
            self.minHeight = 36.0
            self.minWidth = minHeight * 1.8
        }
        
        func getImageInset(forContent contentRect: CGRect) -> CGFloat {
            min(contentRect.width, contentRect.height) * 0.25
        }
        func getImageSide(forContent contentRect: CGRect) -> CGFloat {
            min(contentRect.width, contentRect.height) - (2.0 * getImageInset(forContent: contentRect))
        }
        func getImageRect(forContent contentRect: CGRect) -> CGRect {
            
            let imageSide = getImageSide(forContent: contentRect)
            
            return
                CGRect(
                    origin: CGPoint(
                        x: contentRect.width / 2.0,
                        y: contentRect.height / 2.0
                    ),
                    size: CGSize.zero
                )
                .insetBy(dx: -imageSide / 2.0, dy: -imageSide / 2.0)
        }
    }
}
 
