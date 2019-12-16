//
//  ChooseBarView.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

final class ChooseBarView: UIView {
    
    typealias ElementView = ChooseBarElementView
    typealias ViewItem = ElementView.ViewModel
    typealias ViewAction = (Int) -> Void
    
    unowned private var stackView: UIStackView!
    
    private var elementViews: [ElementView] {
        
        guard let elementViews = stackView.arrangedSubviews as? [ElementView] else {
            preconditionFailure()
        }
        return elementViews
    }
    
    // MARK: - View Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        func makeStackView() -> UIStackView {
            
            let stackView = UIStackView()
            
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 0
            
            return stackView
        }
        
        let stackView = makeStackView()
        embedToBorders(stackView)
        
        self.stackView = stackView
    }
    
    // MARK: - View updates
    
    struct ViewModel {
        let viewItems: [ViewItem]
    }
    
    var viewModel: ViewModel = ViewModel(viewItems: []) {
        didSet {
            invalidateViewElements()
        }
    }
    
    struct ViewStyle {
        let titleFont: UIFont
        let normalTitleColor: UIColor
        let highlightedTitleColor: UIColor
    }
    
    private var _viewStyle: ViewStyle?
    internal var viewStyle: ViewStyle {
        get {
            guard let viewStyle = _viewStyle else {
                preconditionFailure("<Error> ViewStyle must be Injected before View using")
            }
            return viewStyle
        }
        set (newViewStyle) {
            _viewStyle = newViewStyle
            
            elementViews.forEach {
                $0.viewStyle = newViewStyle
            }
        }
    }
    
    private func invalidateViewElements() {
        
        func removeOldViewElements() {
            
            stackView
                .arrangedSubviews
                .forEach {
                    stackView.removeArrangedSubview($0)
                    $0.removeFromSuperview()
                }
        }
        func setNewViewElements() {
            
            viewModel
                .viewItems
                .map { (viewModel: ElementView.ViewModel) -> ElementView in
                    
                    let elementView = ElementView()
                    elementView.viewModel = viewModel
                    elementView.viewStyle = viewStyle
                    return elementView
                }
                .forEach { (elementView: ElementView) in
                
                    subscribeToTapAction(elementView)
                    stackView.addArrangedSubview(elementView)
                }
        }
        
        removeOldViewElements()
        setNewViewElements()
    }
    
    // MARK: - Element Selection
    
    var selectedElementIndex: Int = 0 {
        willSet (elementIndex) {
            assert(
                elementIndex < viewModel.viewItems.count,
                "<Error> ViewItems index out of bounds: (count: \(viewModel.viewItems.count), index: \(elementIndex))"
            )
        }
        didSet {
            setHighlightedElement(by: selectedElementIndex)
        }
    }
    var onElementSelected: ViewAction?
    
    private func setHighlightedElement(by elementIndex: Int) {
        
        elementViews.forEach { $0.setHighlighted(false) }
        elementViews[elementIndex].setHighlighted(true)
    }
    
    // MARK: - Element Taps
    
    private func subscribeToTapAction(_ elementView: ElementView) {
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(elementViewTapped)
        )
        elementView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func elementViewTapped(_ gesture: UIGestureRecognizer) {
        
        guard let tappedView = gesture.view as? ElementView else {
            preconditionFailure()
        }
        guard let elementIndex = elementViews.firstIndex(where: { $0 === tappedView}) else {
            
            assertionFailure("<Error> tapped ElementView (\(tappedView)) not found in elementViews")
            return
        }
        
        self.selectedElementIndex = elementIndex
        onElementSelected?(elementIndex)
    }
}
