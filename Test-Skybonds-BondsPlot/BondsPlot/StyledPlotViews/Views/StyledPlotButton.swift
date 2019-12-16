//
//  StyledPlotButton.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

class StyledPlotButton: UIButton, StyledPlotButtonComponent {
    
    final private var stylizer: StyledPlotStylizer<StyledPlotButton>!
    final private unowned var shadowLayer: CALayer!
    final private unowned var cornersLayer: CALayer!
    
    final var button: StyledPlotButton { return self }
    final let shadowLayerPath: ReferenceWritableKeyPath<StyledPlotButton, CALayer?> = \.shadowLayer
    final let cornersLayerPath: ReferenceWritableKeyPath<StyledPlotButton, CALayer?> = \.cornersLayer
    
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
        subscribeToTapEvents()
    }
    
    func subscribeToTapEvents() {
        
        self.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        
        self.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchUp), for: .touchUpOutside)
    }
    
    @objc func buttonTouchDown() {
        pushTapEffect()
        
    }
    @objc func buttonTouchUp() {
        pullTapEffect()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        stylizer.sendStyleBack()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stylizer.updateStyleAfterLayoutUpdates()
    }
}
