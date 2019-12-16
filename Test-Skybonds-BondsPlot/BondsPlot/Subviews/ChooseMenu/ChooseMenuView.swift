//
//  ChooseMenuView.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

final class ChooseMenuView: StyledPlotView {
    
    typealias ViewAction = (Int) -> Void
    typealias ViewOption = String
    typealias CellAssets = ChooseMenuCell.ViewAssets
    
    var onMenuOptionSelected: ViewAction?
    
    // MARK: - Menu Models
    
    struct ViewModel {
        let viewOptions: [ViewOption]
    }
    
    struct ViewStyle {
        
        let separatorColor: UIColor
        let optionFont: UIFont
        
        let titleNormalColor: UIColor
        let titleSelectedColor: UIColor
        
        let backHighlightedColor: UIColor
    }
    struct ViewLayout {
        let cellHeight: CGFloat
    }
    
    var viewModel = ViewModel(viewOptions: []) {
        didSet {
            assert(viewModel.viewOptions.count > 0, "<Error> ViewModel should be have yet one Option")
            
            // Update content, subviews
            invalidateViewModel()
            
            // Always reset Option Index + prepare cell States
            self.selectedOptionIndex = 0
            
            layoutAssertions()
        }
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
        }
    }
    
    private var _cellAssets: CellAssets?
    internal var cellAssets: CellAssets {
        get {
            guard let cellAssets = _cellAssets else {
                preconditionFailure("<Error> CellAssets must be Injected before View using")
            }
            return cellAssets
        }
        set (newCellAssets) {
            _cellAssets = newCellAssets
            
            menuCells.forEach {
                $0.viewAssets = newCellAssets
            }
        }
    }
    
    private let viewLayout = ViewLayout(cellHeight: 36.0)
    
    private lazy var animator = ViewAnimator(view: self, expandingDuration: 0.4)
    
    // MARK: - Menu Initialization
    
    private var menuCells: [ChooseMenuCell] = []
    private var menuSeparators: [UIView] = []
    
    private var selectedCell: ChooseMenuCell {
        return menuCells[selectedOptionIndex]
    }
    
    private unowned var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    private func initialize() {
        initializeLayout()
        
        // Because StyledPlotView can update his cornerRadius dynamically,
        // This should be disabled
        self.maxCornerRadius = viewLayout.cellHeight / 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCellCorners()
    }
    func updateCellCorners() {
        layoutAssertions()
        
        menuCells
            .forEach { cell in
                
                // For nice Cells highlighting - synchronize with Parent View corners
                
                if menuCells.first == cell {
                    cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    cell.layer.cornerRadius = self.cornerRadius
                }
                if menuCells.last == cell {
                    cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                    cell.layer.cornerRadius = self.cornerRadius
                }
            }
    }
    
    // MARK: - Cell Selection
    
    // Do not cause some Setter handling
    // Public property intended for convenient developer usage
    
    private var _selectedOptionIndex: Int = 0
    
    var selectedOptionIndex: Int {
        get { _selectedOptionIndex }
        set (newOptionIndex) {
            _selectedOptionIndex = newOptionIndex
            
            assert(
                _selectedOptionIndex < menuCells.count,
                "<Error> optionIndex \(_selectedOptionIndex) is out of Bounds, menuCells count = \(menuCells.count)"
            )
            layoutAssertions()
            
            invalidateCellStates()
        }
    }
    
    private func setSelected(byTouches touches: Set<UITouch>, with event: UIEvent?) {
        
        // Locate, which cell was Tapped, then select
        
        guard let tappedCell = findCell(byTouches: touches, with: event) else {
            return
        }
        guard let selectedIndex = menuCells.firstIndex(where: { $0 === tappedCell }) else {
            preconditionFailure("<Error> tappedCell not found in menuCells")
        }
        
        // Do not cause some Setter handling here
        self._selectedOptionIndex = selectedIndex
        onMenuOptionSelected?(_selectedOptionIndex)
    }
    
    private func setHighlighted(byTouches touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let tappedCell = findCell(byTouches: touches, with: event) else {
            return
        }
        tappedCell.setHighlighted(true)
    }
    private func setAllUnhighlighted() {
        
        menuCells.forEach { $0.setHighlighted(false) }
    }
    
    private func findCell(byTouches touches: Set<UITouch>, with event: UIEvent?) -> ChooseMenuCell? {
        
        guard let touch = touches.first else {
            assertionFailure("<Error> touches Set is empty, UITouch not found")
            return nil
        }
        
        return menuCells
            .first {
                let touchLocation = touch.location(in: $0)
                return $0.point(inside: touchLocation, with: event)
            }
    }
    
    // MARK: - View Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Scaling efect -> only when Dropdown not displayed yet
        
        if self.expanded == false {
            pushTapEffect()
        } else {
            animator.animateHighlight {
                self.setHighlighted(byTouches: touches, with: event)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pullTapEffect()
        
        animator.animateHighlight {
            self.setAllUnhighlighted()
        }
        
        // Select and compress Content animately
        
        if self.expanded == true {
            setSelected(byTouches: touches, with: event)
        }
        self.expanded = !self.expanded
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pullTapEffect()
    }
    
    // MARK: - State Logic
    
    var expanded: Bool = false {
        didSet {
            if expanded == true {
                expandMenu()
            } else {
                compressMenu()
            }
        }
    }
    
    private func expandMenu() {
        
        animator.animateMenuOptions {
            
            self.setHeightToCells(self.menuCells.count)
            self.invalidateCellStates()
            self.distributeCells(expanded: true)
            self.setSeparators(hidden: false)
        }
    }
    
    private func compressMenu() {
        
        animator.animateMenuOptions {
            
            self.setHeightToCells(1)
            self.invalidateCellStates()
            self.distributeCells(expanded: false)
            self.setSeparators(hidden: true)
        }
    }
}

// MARK: - Content Layout

private extension ChooseMenuView {
    
    var layoutInitialized: Bool {
        heightConstraint != nil
    }
    var layoutInvalidated: Bool {
        menuCells.count == self.viewModel.viewOptions.count
    }
    
    func layoutAssertions() {
        assert(layoutInitialized == true, "<Error> Layout Should be Initialized")
        assert(layoutInvalidated == true, "<Error> Layout Should be Invalidated after ViewModel updates")
    }
    
    func initializeLayout() {
        assert(layoutInitialized == false, "<Error> Layout Shouldn't be Initialized twice")
        
        let heightConstraint = heightAnchor.constraint(equalToConstant: viewLayout.cellHeight)
        heightConstraint.isActive = true
        self.heightConstraint = heightConstraint
        
        self.maxCornerRadius = viewLayout.cellHeight / 2.0
    }
    
    func setHeightToCells(_ cellsCount: Int) {
        layoutAssertions()
        
        self.heightConstraint.constant = viewLayout.cellHeight * CGFloat(cellsCount)
    }
    
    func distributeCells(expanded: Bool) {
        layoutAssertions()
        
        let nominalCellHeight = expanded ? viewLayout.cellHeight : 0.0
        
        menuCells
            .enumerated()
            .forEach { (index: Int, cell: ChooseMenuCell) in

                let topConstraint =
                    cell
                        .superview?
                        .constraints
                        .first(where: {
                            $0.firstAnchor == cell.topAnchor ||
                            $0.secondAnchor == cell.topAnchor
                        })
                
                assert(topConstraint != nil, "<Error> topConstraint of MenuCell with index=\(index) not found")
                
                topConstraint?.constant = -CGFloat(index) * nominalCellHeight
            }
    }
}

// MARK: - Content Cell States

private extension ChooseMenuView {
    
    private struct CellState {
        
        let selected: Bool
        let expanded: Bool
    }
    
    func invalidateCellStates() {
        
        menuCells
            .forEach {
                setCell($0, state: CellState(
                    selected: $0 === self.selectedCell,
                    expanded: self.expanded
                ))
            }
    }
    
    private func setCell(_ cell: ChooseMenuCell, state: CellState) {
        
        switch (state.selected, state.expanded) {
            
        case (true, true):
            cell.viewModel.arrowDirection = .right
            cell.viewModel.showDownArrow = false
            cell.viewStyle.tintColor = viewStyle.titleSelectedColor
            cell.alpha = 1.0
            
        case (true, false):
            cell.viewModel.arrowDirection = .down
            cell.viewModel.showDownArrow = true
            cell.viewStyle.tintColor = viewStyle.titleNormalColor
            cell.alpha = 1.0
            
        case (false, true):
            cell.viewModel.arrowDirection = .right
            cell.viewModel.showDownArrow = true
            cell.viewStyle.tintColor = viewStyle.titleNormalColor
            cell.alpha = 1.0
            
        case (false, false):
            cell.viewModel.arrowDirection = .down
            cell.viewModel.showDownArrow = false
            cell.viewStyle.tintColor = viewStyle.titleNormalColor
            cell.alpha = 0.0
        }
    }
    
    func setSeparators(hidden: Bool) {
        
        menuSeparators.forEach {
            $0.alpha = hidden ? 0.0 : 1.0
        }
    }
}

// MARK: - Content Animations

private extension ChooseMenuView {
    
    struct ViewAnimator {
        
        private unowned let view: UIView
        let expandingDuration: TimeInterval
        
        init(view: UIView, expandingDuration: TimeInterval) {
            self.view = view; self.expandingDuration = expandingDuration
        }
        
        func animateMenuOptions(_ animations: @escaping () -> Void) {
            
            UIView.animate(
                withDuration: expandingDuration,
                delay: 0.0,
                options: [.curveLinear],
                animations: {
                    
                    animations()
                    self.view.superview?.layoutIfNeeded()
                },
                completion: nil
            )
        }
        func animateHighlight(_ animations: @escaping () -> Void) {
            
            UIView.animate(
                withDuration: 0.15,
                delay: 0.0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: animations,
                completion: nil
            )
        }
    }
}

// MARK: - Content Updates

private extension ChooseMenuView {
    
    func invalidateViewModel() {
        
        let updater = Updater(
            view: self,
            withModel: self.viewModel,
            withStyle: self.viewStyle,
            withLayout: self.viewLayout,
            withAssets: self.cellAssets
        )
        updater.updateContent()
    }
    
    struct Updater {
        
        private unowned let view: ChooseMenuView
        private let viewModel: ViewModel
        private let viewStyle: ViewStyle
        private let viewLayout: ViewLayout
        private let cellAssets: CellAssets
        
        init(view: ChooseMenuView,
             withModel viewModel: ViewModel,
             withStyle viewStyle: ViewStyle,
             withLayout viewLayout: ViewLayout,
             withAssets cellAssets: CellAssets) {
            
            self.view = view;
            self.viewModel = viewModel; self.viewStyle = viewStyle;
            self.viewLayout = viewLayout; self.cellAssets = cellAssets
        }
        
        func updateContent() {
            
            removeOldMenuCells()
            removeOldMenuSeparators()
            
            let menuCells = makeNewMenuCells(
                withModel: self.viewModel,
                withStyle: self.viewStyle,
                withLayout: self.viewLayout,
                withAssets: self.cellAssets
            )
            addMenuCells(menuCells)
            
            let menuSeparators = makeNewMenuSeparators(underCells: menuCells, withStyle: self.viewStyle)
            addMenuSeparators(menuSeparators, underCells: menuCells)
            
            view.menuCells = menuCells
            view.menuSeparators = menuSeparators
        }
        
        private func removeOldMenuCells() {
            
            view.menuCells.forEach { $0.removeFromSuperview() }
            view.menuCells.removeAll()
        }
        private func removeOldMenuSeparators() {
            
            view.menuSeparators.forEach { $0.removeFromSuperview() }
            view.menuSeparators.removeAll()
        }
        
        private func makeNewMenuCells(
            withModel viewModel: ViewModel,
            withStyle viewStyle: ViewStyle,
            withLayout viewLayout: ViewLayout,
            withAssets cellAssets: CellAssets) -> [ChooseMenuCell] {
            
            return viewModel
                .viewOptions
                .map { (viewOption: ViewOption) -> ChooseMenuCell in
                    
                    let menuCell = ChooseMenuCell(
                        withLayout: ChooseMenuCell.ViewLayout(
                            contentHeight: viewLayout.cellHeight
                        )
                    )
                    menuCell.viewModel = ChooseMenuCell.ViewModel(title: viewOption)
                    
                    menuCell.viewStyle = ChooseMenuCell.ViewStyle(
                        titleFont: viewStyle.optionFont,
                        tintColor: viewStyle.titleNormalColor,
                        normalColor: .clear,
                        highlightedColor: viewStyle.backHighlightedColor
                    )
                    menuCell.viewAssets = cellAssets
                
                    return menuCell
                }
        }
        private func addMenuCells(_ menuCells: [ChooseMenuCell]) {
            
            menuCells
                .forEach { cell in
                
                    view.addSubview(cell)
                    cell.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                        view.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                        view.topAnchor.constraint(equalTo: cell.topAnchor)
                    ])
                }
        }
        
        private func makeNewMenuSeparators(underCells menuCells: [UIView], withStyle viewStyle: ViewStyle) -> [UIView] {
            
            return
                (0..<max(0, (menuCells.count - 1)))
                    .map { _ -> UIView in
                        let separator = UIView()
                        separator.backgroundColor = viewStyle.separatorColor
                        separator.alpha = 0.0
                        return separator
                    }
        }
        
        private func addMenuSeparators(_ menuSeparators: [UIView], underCells menuCells: [UIView]) {
            
            assert(menuSeparators.count == menuCells.count - 1, "<Error> MenuSeparators count is Wrong")
            
            menuSeparators
                .enumerated()
                .forEach { (index: Int, separator: UIView) in
                
                    view.addSubview(separator)
                    separator.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        view.leadingAnchor.constraint(equalTo: separator.leadingAnchor),
                        view.trailingAnchor.constraint(equalTo: separator.trailingAnchor),
                        menuCells[index].bottomAnchor.constraint(equalTo: separator.bottomAnchor),
                        separator.heightAnchor.constraint(equalToConstant: 1.0)
                    ])
                }
        }
    }
}
