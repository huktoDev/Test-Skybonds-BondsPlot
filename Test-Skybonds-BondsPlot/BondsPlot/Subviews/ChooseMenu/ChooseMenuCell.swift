//
//  ChooseMenuCell.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

struct PlaceholderStyle {
    
    static let font: UIFont = UIFont.systemFont(ofSize: 10.0)
    static let color: UIColor = .black
}


final class ChooseMenuCell: UIView {
    
    struct ViewModel {
        let title: String
        var arrowDirection: ArrowDirection = .down
        var showDownArrow: Bool = true
    }
    
    struct ViewStyle {
        let titleFont: UIFont
        var tintColor: UIColor
        var normalColor: UIColor
        var highlightedColor: UIColor
        
        init() {
            self.titleFont = PlaceholderStyle.font
            self.tintColor = PlaceholderStyle.color
            self.highlightedColor = PlaceholderStyle.color
            self.normalColor = .clear
        }
        init(titleFont: UIFont, tintColor: UIColor, normalColor: UIColor, highlightedColor: UIColor) {
            self.titleFont = titleFont; self.tintColor = tintColor
            self.normalColor = normalColor; self.highlightedColor = highlightedColor
        }
    }
    
    struct ViewAssets {
        let expandIcon: UIImage
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
            
            arrowView.image = newViewAssets.expandIcon
            
        }
    }
    
    enum ArrowDirection {
        case down
        case right
    }
    
    var viewModel = ViewModel(title: "") {
        didSet {
            invalidateViewModel()
        }
    }
    
    var viewStyle = ViewStyle() {
        didSet {
            invalidateViewStyle()
        }
    }
    
    var viewLayout: ViewLayout
    
    func invalidateViewModel() {
        
        titleLabel.text = viewModel.title
        arrowView.transform = viewModel.arrowDirection.transform()
        arrowView.alpha = viewModel.showDownArrow ? 1.0 : 0.0
    }
    func invalidateViewStyle() {
        
        titleLabel.font = viewStyle.titleFont
        self.tintColor = viewStyle.tintColor
    }
    
    func setHighlighted(_ enabled: Bool) {
        
        self.backgroundColor =
            (enabled == true)
                ? viewStyle.highlightedColor
                : viewStyle.normalColor
    }
    
    // MARK: - View Initialization
    
    private unowned var arrowView: UIImageView!
    private unowned var titleLabel: UILabel!
    
    init(withLayout viewLayout: ViewLayout) {
        self.viewLayout = viewLayout
        super.init(frame: .zero)
        initialize()
    }
    required init?(coder: NSCoder) {
        fatalError("<Error> \(ChooseMenuCell.self) shouldn't be Used from IB")
    }
    private func initialize() {
        
        let initializer = Initializer(
            cell: self,
            withStyle: self.viewStyle,
            withLayout: self.viewLayout
        )
        initializer.initializeContent()
    }
    
    // MARK: - View Events
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        self.titleLabel.textColor = tintColor
    }
}

// MARK: - Cell Initialization & Layout

extension ChooseMenuCell.ArrowDirection {
    
    func transform() -> CGAffineTransform {
        
        switch self {
            case .down:
                return .identity
            case .right:
                return CGAffineTransform
                    .init(rotationAngle: -CGFloat.pi / 2)
                    .scaledBy(x: 0.8, y: 1.0)
        }
    }
}

extension ChooseMenuCell {
    
    struct ViewLayout {
        
        let contentHeight: CGFloat
        let contentMinWidth: CGFloat
        
        let titleLeftInset: CGFloat
        let titleTopInset: CGFloat
        
        let imageRightInset: CGFloat
        let imageTopInset: CGFloat
        let imageSide: CGFloat
        
        init(contentHeight: CGFloat) {
            
            self.contentHeight = contentHeight
            self.contentMinWidth = contentHeight * 3.0
            
            self.titleLeftInset = contentHeight * 0.5
            self.titleTopInset = contentHeight * 0.25
            
            self.imageRightInset = contentHeight * 0.25
            self.imageTopInset = contentHeight * 0.25
            self.imageSide = contentHeight - 2.0 * imageTopInset
        }
    }
    
    override var intrinsicContentSize: CGSize {
            
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: viewLayout.contentHeight
        )
    }
    
    fileprivate struct Initializer {
        
        private unowned let cell: ChooseMenuCell
        private let style: ViewStyle
        private let layout: ViewLayout
        
        init(cell: ChooseMenuCell,
             withStyle viewStyle: ViewStyle,
             withLayout viewLayout: ViewLayout) {
            
            self.cell = cell
            self.style = viewStyle; self.layout = viewLayout
        }
        
        func initializeContent() {
            
            let arrowView = makeArrowImage()
            addArrowImage(arrowView, withLayout: self.layout)
            
            let titleLabel = makeTitleLabel(withStyle: self.style)
            addTitleLabel(titleLabel, withLayout: self.layout)
            
            setWidthLayout(titleLabel, arrowView, withLayout: self.layout)
            
            cell.arrowView = arrowView
            cell.titleLabel = titleLabel
        }
        
        private func makeArrowImage() -> UIImageView {
            
            let arrowView = UIImageView()
            arrowView.contentMode = .scaleToFill
            return arrowView
        }
        private func addArrowImage(_ arrowView: UIView, withLayout viewLayout: ViewLayout) {
            
            cell.addSubview(arrowView)
            arrowView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                cell.trailingAnchor.constraint(equalTo: arrowView.trailingAnchor, constant: viewLayout.imageRightInset),
                cell.topAnchor.constraint(equalTo: arrowView.topAnchor, constant: -viewLayout.imageTopInset),
                arrowView.heightAnchor.constraint(equalToConstant: viewLayout.imageSide),
                arrowView.widthAnchor.constraint(equalToConstant: viewLayout.imageSide)
            ])
        }
        
        private func makeTitleLabel(withStyle viewStyle: ViewStyle) -> UILabel {
            
            let titleLabel = UILabel()
            
            titleLabel.numberOfLines = 1
            titleLabel.textAlignment = .left
            titleLabel.font = viewStyle.titleFont
            
            return titleLabel
        }
        private func addTitleLabel(_ titleLabel: UIView, withLayout viewLayout: ViewLayout) {
            
            cell.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                cell.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -viewLayout.titleLeftInset),
                cell.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -viewLayout.titleTopInset),
                cell.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: viewLayout.titleTopInset)
            ])
        }
        
        private func setWidthLayout(_ titleLabel: UILabel, _ arrowView: UIImageView, withLayout viewLayout: ViewLayout) {
            
            let couplingConstraint = titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowView.leadingAnchor)
            couplingConstraint.priority = .required
            couplingConstraint.isActive = true
            
            let widthConstraint = cell.widthAnchor.constraint(greaterThanOrEqualToConstant: viewLayout.contentMinWidth)
            widthConstraint.isActive = true
        }
    }
}
