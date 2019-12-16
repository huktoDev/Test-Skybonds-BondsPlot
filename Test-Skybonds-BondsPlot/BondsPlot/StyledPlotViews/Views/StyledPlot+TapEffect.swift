//
//  StyledPlot+TapEffect.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

extension UIView {

    private struct TapEffect {
        static let duration: TimeInterval = 0.15
        static let scale: CGFloat = 0.9
    }

    func pushTapEffect() {

        UIView.animate(
            withDuration: TapEffect.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform(
                    scaleX: TapEffect.scale, y: TapEffect.scale
                )
            },
            completion: nil
        )
    }
    func pullTapEffect() {

        UIView.animate(
            withDuration: TapEffect.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform.identity
            },
            completion: nil
        )
    }
}
