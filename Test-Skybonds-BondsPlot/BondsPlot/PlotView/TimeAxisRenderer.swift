//
//  TimeAxisRenderer.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import UIKit
import Charts
import SwiftDate


final class TimeAxisRenderer: XAxisRenderer {
    
    var timeBaseMin: Double!
    var timeBaseMax: Double!
    
    var formatter: TimeAxisFormatter?
    
    var rendered: TimePeriod?
    var slicingStride: DateComponents?
    
    var timeLabelWidthShort: CGFloat?
    var timeLabelWidthWithYear: CGFloat?
    
    override func computeAxis(min: Double, max: Double, inverted: Bool) {
        
        self.timeBaseMin = min
        self.timeBaseMax = max
        
        super.computeAxis(min: min, max: max, inverted: inverted)
    }
    
    override func computeAxisValues(min: Double, max: Double) {
        
        guard let axis = self.axis else { return }
        
        let focused = TimePeriod(
            startDate: Date(timeIntervalSince1970: min),
            endDate: Date(timeIntervalSince1970: max)
        )
        let full = TimePeriod(
            startDate: Date(timeIntervalSince1970: self.timeBaseMin),
            endDate: Date(timeIntervalSince1970: self.timeBaseMax)
        )

        if focused.startDate! > focused.endDate! {
            axis.entries = [Double]()
            axis.centeredEntries = [Double]()
            return
        }
        
        let stride = determineSlicingStride(forPeriod: focused)
        let anchor = getAnchorStridingDate(forPeriod: full, stride: stride)
        
        let timePeriods = slicedTimePeriods(
            inFocused: focused,
            withAnchor: anchor,
            slicingStride: stride
        )
        
        axis.entries = timePeriods.map { $0.startDate!.timeIntervalSince1970 }
        
        self.rendered = focused
        self.slicingStride = stride
    }
    
    func determineSlicingStride(forPeriod timePeriod: TimePeriod) -> DateComponents {
        
        guard let shortLabelWidth = self.timeLabelWidthShort else {
            preconditionFailure("<Error> timeLabelWidthShort should be configured before using")
        }
        guard let yearLabelWidth = self.timeLabelWidthWithYear else {
            preconditionFailure("<Error> timeLabelWidthWithYear should be configured before using")
        }
        guard let labelFormatter = self.formatter else {
            preconditionFailure("<Error> formatter should be injected before using")
        }
        
        let timeMinStrides = [
            1.days, 2.days, 4.days,
            1.weeks, 2.weeks,
            1.months, 2.months, 3.months, 6.months
        ]
        
        let maxShortStridesCount = Int(self.viewPortHandler.chartWidth) / Int(shortLabelWidth)
        let maxMonthsStridesCount = Int(self.viewPortHandler.chartWidth) / Int(yearLabelWidth)
        
        let getMaxStridesCount = { (stride: DateComponents) -> Int in
            
            if labelFormatter.shouldUseShortFormatting(forStride: stride) {
                return maxShortStridesCount
            } else {
                return maxMonthsStridesCount
            }
        }
        
        let preferredTimeStride = timeMinStrides.first {
            
            if let daysInExpectedStride = $0.day {
                if timePeriod.days / daysInExpectedStride <= getMaxStridesCount($0) {
                    return true
                }
            }
            if let weeksInExpectedStride = $0.weekOfYear {
                if timePeriod.weeks / weeksInExpectedStride <= getMaxStridesCount($0) {
                    return true
                }
            }
            if let monthsInExpectedStride = $0.month {
                if timePeriod.months / monthsInExpectedStride <= getMaxStridesCount($0) {
                    return true
                }
            }
            return false
        }
        return preferredTimeStride ?? timeMinStrides.last!
    }
    
    func getAnchorStridingDate(forPeriod timePeriod: TimePeriod, stride slicingStride: DateComponents) -> Date {
        
        let getAnchorDate = { (date: Date, interval: DateComponents) -> Date in
            
            if interval.day != nil {
                return date.dateAtStartOf(.weekOfYear)
            }
            if interval.weekOfYear != nil {
                return date.dateAtStartOf(.month)
            }
            if interval.month != nil {
                return date.dateAtStartOf(.year)
            }
            return date
        }
        return getAnchorDate(timePeriod.startDate!, slicingStride)
    }
    
    func slicedTimePeriods(
        inFocused focused: TimePeriod,
        withAnchor anchorDate: Date,
        slicingStride: DateComponents) -> [TimePeriod] {
        
        var cursor = TimePeriod(
            startDate: anchorDate,
            endDate: anchorDate + slicingStride
        )
        var sliced = [TimePeriod]()
        
        repeat {
            if cursor.overlaps(with: focused) == true {
                sliced.append(cursor)
            }
            cursor = cursor.shifted(by: slicingStride)
        }
        while focused.endDate! > cursor.startDate!
        
        return sliced
    }
}
