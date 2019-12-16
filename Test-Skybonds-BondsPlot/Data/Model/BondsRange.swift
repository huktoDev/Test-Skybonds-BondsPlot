//
//  BondsRange.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import Foundation
import SwiftDate

enum BondsRange: Int, CaseIterable {
    
    case oneWeek
    case oneMonth
    case threeMonths
    case sixMonths
    case oneYear
    case twoYears
    
    static let biggest: BondsRange = .twoYears
    
    private enum Counted {
        
        case weeks(count: Int)
        case months(count: Int)
        case years(count: Int)
        
        var rangeString: String {
            switch self {
                case .weeks(let count): return "\(count)W"
                case .months(let count): return "\(count)M"
                case .years(let count): return "\(count)Y"
            }
        }
    }
    
    private func toCounted() -> Counted {
        
        switch self {
            case .oneWeek: return .weeks(count: 1)
            case .oneMonth: return .months(count: 1)
            case .threeMonths: return .months(count: 3)
            case .sixMonths: return .months(count: 6)
            case .oneYear: return .years(count: 1)
            case .twoYears: return .years(count: 2)
        }
    }
    
    var rangeID: String {
        return toCounted().rangeString
    }
    
    func toDateInterval(startDate: Date = Date().dateAtStartOf(.day)) -> DateInterval {
        
        let endDate = { () -> Date in
            
            switch toCounted() {
            case .weeks(let count):
                return startDate + count.weeks
            case .months(let count):
                return startDate + count.months
            case .years(let count):
                return startDate + count.years
            }
        }()
        
        return DateInterval(start: startDate, end: endDate)
    }
}
