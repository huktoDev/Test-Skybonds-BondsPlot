//
//  PlotAssetsProvider.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 16.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

protocol PlotAssetsProvider {
    
    func expandButtonAssets() -> ExpandButton.ViewAssets
    func chooseMenuAssets() -> ChooseMenuView.CellAssets
}

final class DefaultPlotAssetsProvider: PlotAssetsProvider {
    
    private let traitCollection: UITraitCollection
    init(traitCollection: UITraitCollection) {
        self.traitCollection = traitCollection
    }
    
    private func imageNamed(_ imageName: String) -> UIImage {
        UIImage(
            named: imageName,
            in: Bundle(for: DefaultPlotAssetsProvider.self),
            compatibleWith: traitCollection
        )!
    }
    
    func expandButtonAssets() -> ExpandButton.ViewAssets {
        
        ExpandButton.ViewAssets(
            fullScreenIcon: self.imageNamed("full-screen-icon")
        )
    }
    func chooseMenuAssets() -> ChooseMenuView.CellAssets {
        
        ChooseMenuView.CellAssets(
            expandIcon: self.imageNamed("arrow-down-icon")
        )
    }
}
