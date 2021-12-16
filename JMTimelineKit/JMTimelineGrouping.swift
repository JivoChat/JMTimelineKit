//
//  JMTimelineGrouping.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 22/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

struct JMTimelineGrouping {
    private var groups = [Date]()
    
    var bottomIndex: Int { return 0 }
    var typingIndex: Int { return bottomIndex + 1 }
    var historyFrontIndex: Int { return typingIndex + 1 }
    var historyBackIndex: Int { return historyFrontIndex + groups.count }
    var historyLastIndex: Int { return historyBackIndex - 1 }
    var historyIndices: IndexSet { return IndexSet(integersIn: historyFrontIndex ..< historyBackIndex) }
    var topIndex: Int { return historyBackIndex + 1 }
    
    mutating func grow(date: Date) -> Int? {
        if groups.contains(date) {
            return nil
        }
        else {
            groups = (groups + [date]).sorted(by: >)
            return group(for: date)
        }
    }
    
    func group(for date: Date) -> Int? {
        if let index = groups.firstIndex(of: date) {
            return historyFrontIndex + index
        }
        else {
            return nil
        }
    }
    
    mutating func reset() {
        groups.removeAll()
    }
}
