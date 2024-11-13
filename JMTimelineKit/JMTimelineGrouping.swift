//
//  JMTimelineGrouping.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 22/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

struct JMTimelineGrouping<
    Front: RawRepresentable & CaseIterable,
    Back: RawRepresentable & CaseIterable
> {
    private var groups = [Date]()
    
    var historyFrontIndex: Int {
        return Front.allCases.count
    }
    
    var historyBackIndex: Int {
        return historyFrontIndex + groups.count
    }
    
    var historyLastIndex: Int {
        return historyBackIndex - 1
    }
    
    var historyIndices: IndexSet {
        return IndexSet(integersIn: historyFrontIndex ..< historyBackIndex)
    }
    
    func frontIndex(target: Front) -> Int where Front.RawValue == Int {
        return target.rawValue
    }
    
    func backIndex(target: Back) -> Int where Back.RawValue == Int {
        return historyBackIndex + 1 + target.rawValue
    }
    
    var allIndices: ClosedRange<Int> {
        let upperIndex = historyLastIndex + Back.allCases.count
        return (0 ... upperIndex)
    }
}

extension JMTimelineGrouping {
    mutating func grow(date: Date) -> Int? {
        if groups.contains(date) {
            return nil
        }
        else {
            groups = (groups + [date]).sorted(by: >)
            return section(for: date)
        }
    }
    
    func section(for date: Date) -> Int? {
        if let index = groups.firstIndex(of: date) {
            return historyFrontIndex + index
        }
        else {
            return nil
        }
    }
    
    func group(forSection group: Int) -> Date? {
        let internalIndex = group - historyFrontIndex
        return groups.indices.contains(internalIndex) ? groups[internalIndex] : nil
    }
    
    mutating func reset() {
        groups.removeAll()
    }
}
