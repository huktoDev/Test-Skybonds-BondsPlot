//
//  BondsPlotDIContainer.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

struct BondsPlotDIContainer {
    
    static func prepare(traitCollection: UITraitCollection) {
        
        _shared = BondsPlotDIContainer(
            styleProvider: DefaultPlotStylesProvider(traitCollection: traitCollection),
            assetsProvider: DefaultPlotAssetsProvider(traitCollection: traitCollection),
            dataProvider: BondsDataRepositoryFake()
        )
    }
    private static var _shared: BondsPlotDIContainer!
    static var shared: BondsPlotDIContainer { return _shared }
    
    let styleProvider: PlotStylesProvider
    let assetsProvider: PlotAssetsProvider
    let dataProvider: BondsDataRepository
    
    func makeStylizer<V: StyledPlotButtonComponent>(buttonComponent: V) -> StyledPlotStylizer<V> {
        
        return StyledPlotStylizer(component: buttonComponent)
    }
}
