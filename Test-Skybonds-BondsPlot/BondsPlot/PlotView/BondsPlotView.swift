//
//  BondsPlotView.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit
import Charts
import SwiftDate

final class BondsPlotView: UIView {
    
    unowned private var chartView: LineChartView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        let chartView = LineChartView()
        embedToBorders(chartView)
        
        setupXAxisStyle(chartView)
        setupYAxisStyle(chartView)
        setupLegend(chartView)
        setupLayout(chartView)
        setupUserActions(chartView)
        
        self.chartView = chartView
    }
    
    struct ViewStyle {
        let textFont: UIFont
        let textColor: UIColor
        let lineColor: UIColor
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
            
            invalidateViewStyle()
        }
    }
    
    func invalidateViewStyle() {
        
        chartView.xAxis.labelFont = viewStyle.textFont
        chartView.leftAxis.labelFont = viewStyle.textFont
        
        chartView.xAxis.labelTextColor = viewStyle.textColor
        chartView.leftAxis.labelTextColor = viewStyle.textColor
        
        chartView.data?
            .dataSets
            .compactMap { $0 as? LineChartDataSet }
            .forEach {
                $0.valueFont = viewStyle.textFont
                $0.valueTextColor = viewStyle.textColor
                $0.colors = [viewStyle.lineColor]
            }
        
        updateExpectedXAxisLabelWidth(self.chartView)
    }
    
    struct ViewModel {
        let viewItems: [ViewItem]
        let formatting: (Double) -> String
    }
    
    struct ViewItem {
        let timestamp: Double
        let value: Double
        
        fileprivate func toDataEntry() -> ChartDataEntry {
            
            ChartDataEntry(
                x: timestamp,
                y: value,
                icon: nil
            )
        }
    }
    
    var viewModel = ViewModel(viewItems: [], formatting: { _ in return "" }) {
        didSet {
            invalidatePlotData()
        }
    }
    
    private func invalidatePlotData() {
        
        // Create DataSet & Apply Line/Value styles
        
        let dataSet = LineChartDataSet(
            entries: viewModel.viewItems.map { $0.toDataEntry() },
            label: nil
        )
        setupLine(dataSet)
        setupValueLabels(dataSet, formatting: viewModel.formatting)
        
        // Update Side functionality
        
        guard viewModel.viewItems.count > 0 else {
            return
        }
        guard let firstItem = viewModel.viewItems.first, let lastItem = viewModel.viewItems.last else {
            preconditionFailure()
        }
        
        let firstDate = Date(timeIntervalSince1970: firstItem.timestamp).dateAtStartOf(.day)
        let lastDate = Date(timeIntervalSince1970: lastItem.timestamp).dateAtStartOf(.day)
        
        resetZoomAndPosition()
        updateMaximumScaleByX(first: firstDate, last: lastDate)
        updateSideInsets(first: firstDate, last: lastDate)
        
        // Set Data to Plot
        
        let data = LineChartData(dataSet: dataSet)
        chartView.data = data
    }
    
    private func setupLegend(_ chartView: LineChartView) {
        
        chartView.legend.drawInside = true
        chartView.legend.form = .none
        
        chartView.chartDescription = nil
    }
    
    private func setupLayout(_ chartView: LineChartView) {
        
        chartView.minOffset = 0
        
        chartView.extraTopOffset = 0
        chartView.extraBottomOffset = 0
        chartView.extraLeftOffset = 0
        chartView.extraRightOffset = 0
    }
    
    private func setupUserActions(_ chartView: LineChartView) {
        
        chartView.scaleYEnabled = false
        chartView.highlightPerTapEnabled = false
        chartView.highlightPerDragEnabled = false
    }
}

// MARK: - Side Functionality

private extension BondsPlotView {
    
    func updateMaximumScaleByX(first: Date, last: Date) {
        
        assert(last > first, "<Error> firstDate should be greater than lastDate")
        let period = TimePeriod(startDate: first, endDate: last)
        
        let getScaleX = { () -> CGFloat in
            
            if period.weeks <= 1 {
                return 1.0
            }
            else if period.months <= 2 {
                return CGFloat(period.weeks)
            }
            else if period.months <= 6 {
                return CGFloat(period.months)
            }
            else {
                return CGFloat(period.months) / CGFloat(3)
            }
        }
        chartView.viewPortHandler.setMaximumScaleX(getScaleX())
    }
    func updateSideInsets(first: Date, last: Date) {
        
        assert(last > first, "<Error> firstDate should be greater than lastDate")
        let timeInterval = DateInterval(start: first, end: last).duration
        
        let leftLineRelativeInset = 0.12
        let rightLineRelativeInset = 0.08
        
        chartView.xAxis.spaceMin = timeInterval * leftLineRelativeInset
        chartView.xAxis.spaceMax = timeInterval * rightLineRelativeInset
    }
    func resetZoomAndPosition() {
        chartView.zoom(scaleX: 1.0, scaleY: 1.0, xValue: 0.0, yValue: 0.0, axis: .left)
    }
}

// MARK: - Axis Setup

private extension BondsPlotView {
    
    func setupXAxisStyle(_ chartView: LineChartView) {
        
        chartView.xAxis.yOffset = 24
        chartView.xAxis.labelPosition = .bottomInside
        
        // Create Formatter & Renderer
        
        let timeAxisFormatter = TimeAxisFormatter()
        
        let timeAxisRenderer = TimeAxisRenderer(
            viewPortHandler: chartView.xAxisRenderer.viewPortHandler,
            xAxis: chartView.xAxis,
            transformer: chartView.xAxisRenderer.transformer
        )
        
        timeAxisFormatter.renderer = timeAxisRenderer
        timeAxisRenderer.formatter = timeAxisFormatter
        
        // Install Chart Dependencies
        
        chartView.xAxisRenderer = timeAxisRenderer
        chartView.xAxis.valueFormatter = timeAxisFormatter
        
        updateExpectedXAxisLabelWidth(chartView)
    }
    
    func updateExpectedXAxisLabelWidth(_ chartView: LineChartView) {
        
        guard let timeAxisFormatter = chartView.xAxis.valueFormatter as? TimeAxisFormatter else {
            preconditionFailure("<Error> valueFormatter of xAxis should be \(TimeAxisFormatter.self)")
        }
        guard let timeAxisRenderer = chartView.xAxisRenderer as? TimeAxisRenderer else {
            preconditionFailure("<Error> xAxisRenderer should be \(TimeAxisRenderer.self)")
        }
        
        func getEstimatedWidthForExampleDate(formatString: (Date) -> String) -> CGFloat {
            
            let formatted = formatString(Date()) as NSString
            let labelAttributes = [NSAttributedString.Key.font: chartView.xAxis.labelFont]
            let exampleLabelSize = formatted.size(withAttributes: labelAttributes)
            
            return exampleLabelSize.width + 16.0
        }
        
        let withoutYearWidth = getEstimatedWidthForExampleDate(formatString: { timeAxisFormatter.formatDateWithoutYear($0) })
        let withYearWidth = getEstimatedWidthForExampleDate(formatString: { timeAxisFormatter.formatDateWithYear($0) })
        
        timeAxisRenderer.timeLabelWidthShort = withoutYearWidth
        timeAxisRenderer.timeLabelWidthWithYear = withYearWidth
    }
    
    func setupYAxisStyle(_ chartView: LineChartView) {
        
        chartView.rightAxis.enabled = false
        
        chartView.leftAxis.drawAxisLineEnabled = false
              
        chartView.leftAxis.labelAlignment = .right
        chartView.leftAxis.xOffset = 8
        chartView.leftAxis.labelPosition = .insideChart
        
        chartView.leftAxis.spaceBottom = 0.45
        chartView.leftAxis.spaceTop = 0.45
        chartView.leftAxis.drawGridLinesEnabled = true
        
        chartView.leftAxis.labelCount = 5
        chartView.leftAxis.forceLabelsEnabled = true
        
        chartView.leftAxis.drawBottomYLabelEntryEnabled = false
        chartView.leftAxis.drawTopYLabelEntryEnabled = false
    }
}

// MARK: - Values & Line

final class LineValuesFormatter: IValueFormatter {
    
    private let visibleCount: Int = 8
    private let dataSet: LineChartDataSet
    private let formatting: (Double) -> String
    
    init(dataSet: LineChartDataSet, formatting: @escaping (Double) -> String) {
        self.dataSet = dataSet
        self.formatting = formatting
    }
    
    var valuesFrequency = 0
    var displayingEntries = Set<ChartDataEntry>()

    func stringForValue(
        _ value: Double,
        entry: ChartDataEntry,
        dataSetIndex: Int,
        viewPortHandler: ViewPortHandler?) -> String {
        
        assert(viewPortHandler != nil, "<Error> viewPortHandler shouldn't be nil")
        
        let valuesCount = dataSet.entries.count
        let viewPortValuesCount = (valuesCount / Int(viewPortHandler!.scaleX))
        
        let newValuesFrequency = Int(pow(2, log2(Double(viewPortValuesCount))) / Double((visibleCount / 2) + 1))
        if valuesFrequency != newValuesFrequency {
        
            self.displayingEntries =
                Set<ChartDataEntry>(
                    dataSet
                        .entries
                        .enumerated()
                        .filter { $0.offset % newValuesFrequency == 0 }
                        .map { $0.element }
                )
            
            self.valuesFrequency = newValuesFrequency
        }
        
        if displayingEntries.contains(entry) {
            return formatting(value)
        } else {
            return ""
        }
    }
}

private extension BondsPlotView {
    
    func setupLine(_ dataSet: LineChartDataSet) {
        
        dataSet.drawIconsEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.lineWidth = 3
        dataSet.lineCapType = .round
    }
    func setupValueLabels(_ dataSet: LineChartDataSet, formatting: @escaping (Double) -> String) {
        
        dataSet.drawValuesEnabled = true
        
        dataSet.valueFont = viewStyle.textFont
        dataSet.valueColors = [viewStyle.textColor]
        dataSet.valueFormatter = LineValuesFormatter(dataSet: dataSet, formatting: formatting)
        
        dataSet.colors = [viewStyle.lineColor]
        dataSet.circleRadius = 2.0
        
        chartView.maxVisibleCount = (Int.max / 100)
    }
}

