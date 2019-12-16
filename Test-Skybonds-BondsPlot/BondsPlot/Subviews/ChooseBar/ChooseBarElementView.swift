//
//  ChooseBarElementView.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

final class ChooseBarElementView: UIView {
    
    unowned private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        func makeTitleLabel() -> UILabel {
            
            let titleLabel = UILabel()
            
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .center
            
            return titleLabel
        }
        
        let titleLabel = makeTitleLabel()
        embedInCenter(titleLabel)
        
        self.titleLabel = titleLabel
    }
    
    func setHighlighted(_ enabled: Bool) {
        titleLabel.isHighlighted = enabled
    }
    
    struct ViewModel {
        let title: String
    }
    
    var viewModel: ViewModel = ViewModel(title: "") {
        didSet {
            titleLabel.text = viewModel.title
        }
    }
    
    private var _viewStyle: ChooseBarView.ViewStyle?
    internal var viewStyle: ChooseBarView.ViewStyle {
        get {
            guard let viewStyle = _viewStyle else {
                preconditionFailure("<Error> ViewStyle must be Injected before View using")
            }
            return viewStyle
        }
        set (newViewStyle) {
            _viewStyle = newViewStyle
            
            invalidateViewStyle()
        }
    }
    
    func invalidateViewStyle() {
        
        titleLabel.textColor = viewStyle.normalTitleColor
        titleLabel.highlightedTextColor = viewStyle.highlightedTitleColor
        titleLabel.font = viewStyle.titleFont
    }
}
