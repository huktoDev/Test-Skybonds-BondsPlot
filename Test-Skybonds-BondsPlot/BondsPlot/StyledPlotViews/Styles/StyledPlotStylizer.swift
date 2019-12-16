//
//  StyledPlotStylizer.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

protocol StyledPlotButtonComponent: AnyObject {
    
    associatedtype Button where Button: UIView
    var button: Button { get }
    var shadowLayerPath: ReferenceWritableKeyPath<Button, CALayer?> { get }
    var cornersLayerPath: ReferenceWritableKeyPath<Button, CALayer?> { get }
}

class StyledPlotStylizer <ButtonComponent: StyledPlotButtonComponent> {
    
    private unowned let component: ButtonComponent
    
    var buttonStyle: StyledPlotButtonStyle? {
        didSet {
            invalidateLayerStyles()
        }
    }
    
    private var shadowLayer: CALayer {
        return component.button[keyPath: component.shadowLayerPath]!
    }
    private var cornersLayer: CALayer {
        return component.button[keyPath: component.cornersLayerPath]!
    }
    private var contentLayer: CALayer {
        return component.button.layer
    }
    
    init(component: ButtonComponent) {
        self.component = component
    }
    
    func initializeStyleLayers() {
        
        let shadowLayer = makeShadowLayer()
        let cornersLayer = makeCornersLayer()
        
        contentLayer.addSublayer(shadowLayer)
        contentLayer.addSublayer(cornersLayer)
        
        component.button[keyPath: component.shadowLayerPath] = shadowLayer
        component.button[keyPath: component.cornersLayerPath] = cornersLayer
        
        contentLayer.backgroundColor = UIColor.clear.cgColor
        
        component.button.clipsToBounds = false
        contentLayer.masksToBounds = false
        
        shadowLayer.masksToBounds = false
        cornersLayer.masksToBounds = true
    }
    func updateStyleAfterLayoutUpdates() {
        
        shadowLayer.frame = contentLayer.bounds
        cornersLayer.frame = contentLayer.bounds
        
        guard let viewStyle = self.buttonStyle else {
            return
        }
        
        cornersLayer.cornerRadius = viewStyle.corners.radiusBuilder(viewStyle, contentLayer.bounds)
        shadowLayer.shadowPath = viewStyle.shadow.pathBuilder(viewStyle, contentLayer.bounds).cgPath
    }
    func sendStyleBack() {
        
        contentLayer.insertSublayer(shadowLayer, at: 0)
        contentLayer.insertSublayer(cornersLayer, at: 1)
    }
    
    private func makeShadowLayer() -> CALayer {
        
        let layer = CALayer()
        return layer
    }
    private func makeCornersLayer() -> CALayer {
        
        let layer = CALayer()
        //layer.backgroundColor = viewStyle.color.cgColor
        return layer
    }
    
    private func invalidateLayerStyles() {
        
        guard let viewStyle = self.buttonStyle else {
            return
        }
        
        shadowLayer.shadowOpacity = viewStyle.shadow.opacity
        shadowLayer.shadowOffset = viewStyle.shadow.offset
        shadowLayer.shadowRadius = viewStyle.shadow.radius
        shadowLayer.shadowColor = viewStyle.shadow.color.cgColor
        
        cornersLayer.backgroundColor = viewStyle.color.cgColor
        
        cornersLayer.cornerRadius = viewStyle.corners.radiusBuilder(viewStyle, contentLayer.bounds)
        shadowLayer.shadowPath = viewStyle.shadow.pathBuilder(viewStyle, contentLayer.bounds).cgPath
    }
}
