//
//  TimeAxisFormatter.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 16.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import Foundation
import Charts

final class TimeAxisFormatter: IAxisValueFormatter {
    
    weak var renderer: TimeAxisRenderer?
    
    func stringForValue(_ value: Double,
                        axis: AxisBase?) -> String {
        
        guard let timeRenderer = self.renderer else {
            preconditionFailure("<Error> renderer should be Injected before Using")
        }
        guard let stride = timeRenderer.slicingStride else {
            assertionFailure("<Error> TimeFormatter should be executed after Values Rendering")
            return "-"
        }
        
        if shouldUseShortFormatting(forStride: stride) == true {
            return formatDateWithoutYear(Date(timeIntervalSince1970: value))
        } else {
            return formatDateWithYear(Date(timeIntervalSince1970: value))
        }
    }
    
    lazy var withYearFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.yyyy"
        return formatter
    }()
    
    lazy var withoutYearFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    func formatDateWithYear(_ date: Date) -> String {
        return withYearFormatter.string(from: date)
    }
    func formatDateWithoutYear(_ date: Date) -> String {
        return withoutYearFormatter.string(from: date)
    }
    
    func shouldUseShortFormatting(forStride slicingStride: DateComponents) -> Bool {
        
        if let _ = slicingStride.day {
            return true
        }
        if let _ = slicingStride.weekOfYear {
            return true
        }
        return false
    }
}
