//
//  PlotStylesProvider.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

protocol PlotStylesProvider {
    
    func buttonStyle() -> StyledPlotButtonStyle
    func chooseMenuStyle() -> ChooseMenuView.ViewStyle
    func chooseBarStyle() -> ChooseBarView.ViewStyle
    func plotStyle() -> BondsPlotView.ViewStyle
}

final class DefaultPlotStylesProvider: PlotStylesProvider {
    
    private let traitCollection: UITraitCollection
    init(traitCollection: UITraitCollection) {
        self.traitCollection = traitCollection
    }
    
    func buttonStyle() -> StyledPlotButtonStyle {
        
        StyledPlotButtonStyle(
            color: .white,
            shadow: StyledPlotButtonStyle.Shadow(
                opacity: 0.3,
                offset: CGSize(width: 0, height: 1.5),
                radius: 2,
                color: .darkGray,
                pathBuilder: { (style, frame) -> UIBezierPath in
                    UIBezierPath(
                        roundedRect: frame,
                        cornerRadius: style.corners.radiusBuilder(style, frame)
                    )
                }
            ),
            corners: StyledPlotButtonStyle.Corners(
                radiusBuilder: { (style, frame) -> CGFloat in
                    min(frame.width, frame.height) / 2
                }
            )
        )
    }
    func chooseMenuStyle() -> ChooseMenuView.ViewStyle {
        
        ChooseMenuView.ViewStyle(
            separatorColor: .lightGray,
            optionFont: self.labelsFont,
            titleNormalColor: self.labelsColor,
            titleSelectedColor: self.highlightedColor,
            backHighlightedColor: UIColor(white: 0.5, alpha: 0.2)
        )
    }
    func chooseBarStyle() -> ChooseBarView.ViewStyle {
        
        ChooseBarView.ViewStyle(
            titleFont: self.labelsFont,
            normalTitleColor: self.labelsColor,
            highlightedTitleColor: self.highlightedColor
        )
    }
    
    func plotStyle() -> BondsPlotView.ViewStyle {
        
        BondsPlotView.ViewStyle(
            textFont: self.plotLabelsFont,
            textColor: self.labelsColor,
            lineColor: self.lineColor
        )
    }
    
    private let labelsColor: UIColor = .black
    private let highlightedColor: UIColor = UIColor(hex: "#5881c6ff")!
    private let lineColor: UIColor = UIColor(hex: "#ef6e80ff")!
    
    private let labelsFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    private let plotLabelsFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: .bold)
}
