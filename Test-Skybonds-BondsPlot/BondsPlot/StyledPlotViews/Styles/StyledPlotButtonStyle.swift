//
//  StyledPlotButtonStyle.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

struct StyledPlotButtonStyle {
    
    let color: UIColor
    let shadow: Shadow
    let corners: Corners
    
    struct Shadow {
        let opacity: Float
        let offset: CGSize
        let radius: CGFloat
        let color: UIColor
        let pathBuilder: (StyledPlotButtonStyle, CGRect) -> UIBezierPath
    }
    struct Corners {
        let radiusBuilder: (StyledPlotButtonStyle, CGRect) -> CGFloat
    }
}
