//
//  StyledPlotView.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

class StyledPlotView: UIView, StyledPlotButtonComponent {
    
    var cornerRadius: CGFloat { return cornersLayer.cornerRadius }
    var maxCornerRadius: CGFloat = .greatestFiniteMagnitude
    
    final private var stylizer: StyledPlotStylizer<StyledPlotView>!
    final unowned private var shadowLayer: CALayer!
    final unowned private var cornersLayer: CALayer!
    
    final var button: StyledPlotView { return self }
    final let shadowLayerPath: ReferenceWritableKeyPath<StyledPlotView, CALayer?> = \.shadowLayer
    final let cornersLayerPath: ReferenceWritableKeyPath<StyledPlotView, CALayer?> = \.cornersLayer
    
    var buttonStyle: StyledPlotButtonStyle? {
        didSet {
            stylizer.buttonStyle = self.buttonStyle
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        self.stylizer = BondsPlotDIContainer.shared.makeStylizer(buttonComponent: self)
        stylizer.initializeStyleLayers()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        stylizer.sendStyleBack()
    }
    
    // MARK: - Layers Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let viewStyle = self.buttonStyle else {
            return
        }
        
        cornersLayer.cornerRadius =
            min(
                viewStyle.corners.radiusBuilder(viewStyle, layer.bounds),
                maxCornerRadius
            )
        
        let isViewInitializing: Bool =
            shadowLayer.frame == .zero ||
            cornersLayer.frame == .zero ||
            shadowLayer.shadowPath == nil
        
        if isViewInitializing == false {
            
            // Inject CA animations In default AutoLayout flow
            updateLayersToNewFrame(layer.bounds, duration: UIView.inheritedAnimationDuration)
        } else {
            shadowLayer.frame = layer.bounds
            cornersLayer.frame = layer.bounds
            
            let newShadowPath = UIBezierPath(
                roundedRect: layer.bounds,
                cornerRadius: cornersLayer.cornerRadius
            )
            shadowLayer.shadowPath = newShadowPath.cgPath
        }
    }
    
    // MARK: - CA Layers Animations
    
    func updateLayersToNewFrame(_ newFrame: CGRect, duration: TimeInterval) {
        
        updateLayerToNewFrame(newFrame, forLayer: self.shadowLayer, duration: duration) {
            
            // Shadows should be also Animated along Frame animations
            let newShadowPath = UIBezierPath(
                roundedRect: self.layer.bounds,
                cornerRadius: self.cornersLayer.cornerRadius
            )
            let shadowAnimation = CABasicAnimation(
                keyPath: NSStringFromSelector(#selector(getter: self.shadowLayer.shadowPath)) as String
            )
            shadowAnimation.fromValue = self.shadowLayer.shadowPath
            shadowAnimation.toValue = newShadowPath.cgPath
            self.shadowLayer.shadowPath = newShadowPath.cgPath
            
            return [shadowAnimation]
        }
        
        updateLayerToNewFrame(newFrame, forLayer: self.cornersLayer, duration: duration)
    }
    
    func updateLayerToNewFrame(
        _ newFrame: CGRect,
        forLayer layer: CALayer,
        duration: TimeInterval, additionalAnimations: (() -> [CAAnimation])? = nil) {
        
        // Create Position Animation
        let newPosition = CGPoint(
            x: newFrame.minX + newFrame.width / 2.0,
            y: newFrame.minY + newFrame.height / 2.0
        )
        let positionAnimation = CABasicAnimation(
            keyPath: NSStringFromSelector(#selector(getter: layer.position)) as String
        )
        positionAnimation.fromValue = NSValue(cgPoint: layer.position)
        positionAnimation.toValue = NSValue(cgPoint: newPosition)
        layer.position = newPosition
        
        // Create Bounds Animation
        let newBounds = CGRect(origin: .zero, size: newFrame.size)
        let boundsAnimation = CABasicAnimation(
            keyPath: NSStringFromSelector(#selector(getter: layer.bounds)) as String
        )
        boundsAnimation.fromValue = NSValue(cgRect: layer.bounds)
        boundsAnimation.toValue = NSValue(cgRect: newBounds)
        layer.bounds = newBounds
        
        // Put these Animations in Group
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [positionAnimation, boundsAnimation]
        
        if let otherAnimations = additionalAnimations?() {
            animationGroup.animations! += otherAnimations
        }
        
        animationGroup.duration = duration
        
        animationGroup.isRemovedOnCompletion = false
        animationGroup.fillMode = .forwards
        
        layer.add(animationGroup, forKey: "frameUpdates")
    }
}
