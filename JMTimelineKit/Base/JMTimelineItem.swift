//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineItemLayoutValues: JMTimelineStyle {
    public let margins: UIEdgeInsets
    public let groupingCoef: CGFloat
    
    public init(
        margins: UIEdgeInsets,
        groupingCoef: CGFloat
    ) {
        self.margins = margins
        self.groupingCoef = groupingCoef
    }
}

public struct JMTimelineLogicOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let isVirtual = Self.init(rawValue: 1 << 0)
    public static let enableSizeCaching = Self.init(rawValue: 1 << 1)
    public static let missingHistoryPast = Self.init(rawValue: 1 << 2)
    public static let missingHistoryFuture = Self.init(rawValue: 1 << 3)
    public static let loadingHistoryPast = Self.init(rawValue: 1 << 4)
    public static let loadingHistoryFuture = Self.init(rawValue: 1 << 5)
}

public struct JMTimelineLayoutOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let groupTopMargin = JMTimelineLayoutOptions(rawValue: 1 << 0)
    public static let groupFirstElement = JMTimelineLayoutOptions(rawValue: 1 << 1)
    public static let groupLastElement = JMTimelineLayoutOptions(rawValue: 1 << 2)
    public static let groupBottomMargin = JMTimelineLayoutOptions(rawValue: 1 << 3)
    public static let allOptions = JMTimelineLayoutOptions(rawValue: ~0)
}

public class JMTimelineItemPayload {
    public let object: JMTimelineInfo
    public let style: JMTimelineStyle
    
    public init(object: JMTimelineInfo,
                style: JMTimelineStyle) {
        self.object = object
        self.style = style
    }
}

public typealias JMTimelineItemZoneProvider = (JMTimelineItem) -> UIView

open class JMTimelineItem: Equatable, Hashable {
    public let uid: String
    public let date: Date
    public let layoutValues: JMTimelineItemLayoutValues
    public let logicOptions: JMTimelineLogicOptions
    public private(set) var layoutOptions: JMTimelineLayoutOptions

    public init(
        uid: String,
        date: Date,
        layoutValues: JMTimelineItemLayoutValues,
        logicOptions: JMTimelineLogicOptions
    ) {
        self.uid = uid
        self.date = date
        self.layoutValues = layoutValues
        self.logicOptions = logicOptions
        self.layoutOptions = .allOptions
    }

    open var groupingID: String? {
        return uid
    }
    
    open var interactiveID: String? {
        return nil
    }
    
    public var hashValue: Int {
        return uid.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }

    final func addLayoutOptions(_ options: JMTimelineLayoutOptions) {
        layoutOptions.formUnion(options)
    }
    
    public final func hasLayoutOptions(_ options: JMTimelineLayoutOptions) -> Bool {
        return layoutOptions.contains(options)
    }
    
    final func removeLayoutOptions(_ options: JMTimelineLayoutOptions) {
        layoutOptions.subtract(options)
    }
    
    func equal(to another: JMTimelineItem) -> Bool {
        guard uid == another.uid else { return false }
        return true
    }
    
    public static func ==(lhs: JMTimelineItem, rhs: JMTimelineItem) -> Bool {
        return lhs.equal(to: rhs)
    }
}

public extension JMTimelineItem {
    func convert<T>(to: T.Type) -> T {
        return self as! T
    }
}
