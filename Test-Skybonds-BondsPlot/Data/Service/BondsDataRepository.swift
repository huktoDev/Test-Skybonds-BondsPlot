//
//  BondsDataRepository.swift
//  Test-Skybonds-BondsPlot
//
//  Created by Alexandr Babenko on 15.12.2019.
//  Copyright © 2019 Alexandr Babenko. All rights reserved.
//

import Foundation

protocol BondsDataRepository: AnyObject {
    
    func obtainBondHistory(byISIN bondISIN: String, _ completion: (Result<[BondRecordModel], Error>) -> Void)
}

// MARK: - Fake Implementation

class BondsDataRepositoryFake: BondsDataRepository {
    
    func obtainBondHistory(byISIN bondISIN: String, _ completion: (Result<[BondRecordModel], Error>) -> Void) {
        
        completion(.success(
            stride(on: BondsRange.biggest.toDateInterval(), by: 1.days)
                .reduce(into: [BondRecordModel](), {
                    (records: inout [BondRecordModel], dayDate: Date) -> () in
                    
                    let priceValue: Double = {
                        if let previous = records.last {
                            return previous.price + (Double(arc4random() % 10) - 4)
                        } else {
                            return Double(Int.random(in: 100...1000)) + Double(arc4random() % 1000)
                        }
                    }()
                    
                    let yieldValue: Double = {
                        if let previous = records.last {
                            return previous.yield + (0.001 * (Double(arc4random() % 9) - 4))
                        } else {
                            return 0.0
                        }
                    }()

                    let newRecord = BondRecordModel(
                        date: dayDate,
                        price: priceValue,
                        yield: yieldValue
                    )
                    records.append(newRecord)
                })
        ))
    }
}

// MARK: - Data Strideable
import SwiftDate

private func stride(fromDate start: Date, toDate end: Date, byInterval stride: DateComponents) -> [Date] {
    
    // TODO: Check to start < end
    
    var cursorDate = start
    var collectedDates = [Date]()
    
    repeat {
        collectedDates.append(cursorDate)
        cursorDate = cursorDate + stride
    }
    while cursorDate < end
    
    return collectedDates
}
private func stride(on dateInterval: DateInterval, by dateComponents: DateComponents) -> [Date] {
    
    return stride(
        fromDate: dateInterval.start,
        toDate: dateInterval.end,
        byInterval: dateComponents
    )
}
