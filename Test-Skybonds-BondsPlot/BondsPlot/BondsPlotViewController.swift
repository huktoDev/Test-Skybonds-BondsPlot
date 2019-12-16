//
//  BondsPlotViewController.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 13.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit

final class BondsPlotViewController : UIViewController {
    
    @IBOutlet private weak var plotView: BondsPlotView!
    @IBOutlet private weak var rangesView: ChooseBarView!
    @IBOutlet private weak var typeMenuView: ChooseMenuView!
    
    @IBOutlet weak var expandButton: ExpandButton!
    
    private lazy var dataProvider = BondsPlotDIContainer.shared.dataProvider
    private lazy var styleProvider = BondsPlotDIContainer.shared.styleProvider
    private lazy var assetsProvider = BondsPlotDIContainer.shared.assetsProvider
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    func initialize() {
        BondsPlotDIContainer.prepare(traitCollection: self.traitCollection)
    }
    
    var bondISIN: String? {
        didSet {
            obtainBondData()
        }
    }
    
    private let timeRanges = BondsRange.allCases
    private let valueTypes = BondsValue.allCases
    
    private var plotData: [BondRecordModel]? {
        didSet {
            invalidatePlotData()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1.0 / UIScreen.main.scale
        
        setupViewStyles()
        setupViewAssets()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        obtainBondData()
        
        setupViewEvents()
        setupTimeRanges()
        setupValueTypes()
        
        chooseTimeRange(.oneWeek)
        chooseValueType(.yield)
        
        invalidatePlotData()
    }
    
    private func obtainBondData() {
        
        if let bondISIN = self.bondISIN {
            
            dataProvider.obtainBondHistory(byISIN: bondISIN) { [weak self] result in
                
                switch result {
                case .success(let bondRecords):
                    self?.plotData = bondRecords
                case .failure(let error):
                    assertionFailure("<Error> Something went wrong while Bonds were Downloading: \(error)")
                }
            }
        }
    }
    
    private func setupViewEvents() {
        
        rangesView.onElementSelected = { [unowned self] _ in
            self.invalidatePlotData()
        }
        typeMenuView.onMenuOptionSelected = { [unowned self] _ in
            self.invalidatePlotData()
        }
    }
    
    private func setupViewStyles() {
        
        expandButton.buttonStyle = styleProvider.buttonStyle()
        typeMenuView.buttonStyle = styleProvider.buttonStyle()
        
        plotView.viewStyle = styleProvider.plotStyle()
        rangesView.viewStyle = styleProvider.chooseBarStyle()
        typeMenuView.viewStyle = styleProvider.chooseMenuStyle()
    }
    private func setupViewAssets() {
        
        typeMenuView.cellAssets = assetsProvider.chooseMenuAssets()
        expandButton.viewAssets = assetsProvider.expandButtonAssets()
    }
}

// MARK: - Control Views Setup

fileprivate extension BondsValue {
    
    func toString() -> String {
        switch self {
        case .price:
            return "PRICE"
        case .yield:
            return "YIELD"
        }
    }
}

fileprivate extension BondsRange {
    
    func toString() -> String {
        return rangeID
    }
}

private extension BondsPlotViewController {
    
    func setupTimeRanges() {
        
        rangesView.viewModel =
            ChooseBarView.ViewModel(
                viewItems: timeRanges.map {
                    ChooseBarView.ViewItem(title: $0.toString())
                }
            )
    }
    func setupValueTypes() {
        
        typeMenuView.viewModel =
            ChooseMenuView.ViewModel(
                viewOptions: valueTypes.map { $0.toString() }
            )
    }
}

// MARK: - Safe Programmatic Selection

private extension BondsPlotViewController {
    
    func chooseTimeRange(_ timeRange: BondsRange) {
        
        guard let elementIndex = timeRanges.firstIndex(where: { $0 == timeRange }) else {
            
            assertionFailure("<Error> Unknown timeRange: \(timeRange)")
            return
        }
        rangesView.selectedElementIndex = elementIndex
    }
    func chooseValueType(_ valueType: BondsValue) {
        
        guard let optionIndex = valueTypes.firstIndex(where: { $0 == valueType }) else {
            
            assertionFailure("<Error> Unknown valueType: \(valueType)")
            return
        }
        typeMenuView.selectedOptionIndex = optionIndex
    }
}



// MARK: - Plot Data Updates

fileprivate extension BondsValue {
    
    private static let priceFormatter: NumberFormatter = {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        return formatter
    }()
    
    func getFormattingFunction() -> ((Double) -> String) {
        switch self {
        case .price:
            return { BondsValue.priceFormatter.string(from: NSNumber(value: $0))! }
        case .yield:
            return { String($0) }
        }
    }
}

fileprivate extension BondsPlotView.ViewItem {
    
    init(from bondRecord: BondRecordModel, valuePath: KeyPath<BondRecordModel, Double>) {
        
        self.timestamp = bondRecord.date.timeIntervalSince1970
        
        let getRoundedValue = { (value: Double) -> Double in
            
            switch valuePath {
                
            case \.price:
                return (value * pow(10, 2)).rounded(.toNearestOrEven) / pow(10, 2)
            case \.yield:
                return (value * pow(10, 3)).rounded(.toNearestOrEven) / pow(10, 3)
            default:
                preconditionFailure()
            }
        }
        self.value = getRoundedValue(bondRecord[keyPath: valuePath])
    }
}

private extension BondsPlotViewController {
    
    func invalidatePlotData() {
        
        precondition(rangesView.selectedElementIndex < timeRanges.count, "<Error> selectedElementIndex is out of Bounds")
        precondition(typeMenuView.selectedOptionIndex < valueTypes.count, "<Error> selectedOptionIndex is out of Bounds")
        
        let selectedTimeRange = timeRanges[rangesView.selectedElementIndex]
        let selectedValueType = valueTypes[typeMenuView.selectedOptionIndex]
        
        let plotData = self.getPlotData(
            by: selectedTimeRange,
            andValue: selectedValueType
        )
        self.plotView.viewModel = BondsPlotView.ViewModel(
            viewItems: plotData,
            formatting: selectedValueType.getFormattingFunction()
        )
    }
    
    func getPlotData(by bondsRange: BondsRange, andValue valueType: BondsValue) -> [BondsPlotView.ViewItem] {
        
        guard let plotData = self.plotData else {
            return []
        }

        let dateInterval = bondsRange.toDateInterval()
        
        let valuePath: KeyPath<BondRecordModel, Double> = {
            switch valueType {
                case .price: return \.price
                case .yield: return \.yield
            }
        }()
        
        return plotData
            .filter { dateInterval.contains($0.date) }
            .map {
                BondsPlotView.ViewItem(from: $0, valuePath: valuePath)
            }
    }
}
