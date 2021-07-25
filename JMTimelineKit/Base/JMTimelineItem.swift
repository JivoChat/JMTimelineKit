//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineItemStyle: JMTimelineStyle {
    let margins: UIEdgeInsets
    let groupingCoef: CGFloat
    let contentStyle: JMTimelineStyle
    
    public init(margins: UIEdgeInsets,
                groupingCoef: CGFloat,
                contentStyle: JMTimelineStyle) {
        self.margins = margins
        self.groupingCoef = groupingCoef
        self.contentStyle = contentStyle
    }
}

public struct JMTimelineExtraOptions {
    let reactions: [JMTimelineReactionMeta]
    let actions: [JMTimelineActionMeta]
    
    public init(reactions: [JMTimelineReactionMeta], actions: [JMTimelineActionMeta]) {
        self.reactions = reactions
        self.actions = actions
    }
}

public struct JMTimelineReactionMeta {
    let emoji: String
    let number: Int
    let participated: Bool
    
    public init(emoji: String, number: Int, participated: Bool) {
        self.emoji = emoji
        self.number = number
        self.participated = participated
    }
}

public struct JMTimelineActionMeta {
    let ID: String
    let icon: UIImage
    
    public init(ID: String, icon: UIImage) {
        self.ID = ID
        self.icon = icon
    }
}

public struct JMTimelineReactionStyle: JMTimelineStyle {
    public struct Element {
        let paddingCoef: CGFloat
        let fontReducer: CGFloat
        let pullingCoef: CGFloat
        public init(paddingCoef: CGFloat, fontReducer: CGFloat, pullingCoef: CGFloat) {
            self.paddingCoef = paddingCoef
            self.fontReducer = fontReducer
            self.pullingCoef = pullingCoef
        }
    }
    
    let height: CGFloat
    let baseFont: UIFont
    let regularBackgroundColor: UIColor
    let regularNumberColor: UIColor
    let selectedBackgroundColor: UIColor
    let selectedNumberColor: UIColor
    let sidePaddingCoef: CGFloat
    let emojiElement: Element
    let counterElement: Element
    let actionElement: Element

    public init(height: CGFloat,
                baseFont: UIFont,
                regularBackgroundColor: UIColor,
                regularNumberColor: UIColor,
                selectedBackgroundColor: UIColor,
                selectedNumberColor: UIColor,
                sidePaddingCoef: CGFloat,
                emojiElement: Element,
                counterElement: Element,
                actionElement: Element) {
        self.height = height
        self.baseFont = baseFont
        self.regularBackgroundColor = regularBackgroundColor
        self.regularNumberColor = regularNumberColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.selectedNumberColor = selectedNumberColor
        self.sidePaddingCoef = sidePaddingCoef
        self.emojiElement = emojiElement
        self.counterElement = counterElement
        self.actionElement = actionElement
    }
}

public struct JMTimelineRenderOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let groupTopMargin = JMTimelineRenderOptions(rawValue: 1 << 0)
    public static let groupFirstElement = JMTimelineRenderOptions(rawValue: 1 << 1)
    public static let groupLastElement = JMTimelineRenderOptions(rawValue: 1 << 2)
    public static let groupBottomMargin = JMTimelineRenderOptions(rawValue: 1 << 3)
    public static let allOptions = JMTimelineRenderOptions(rawValue: ~0)
}

public class JMTimelineItemPayload {
    public let object: JMTimelineObject
    public let style: JMTimelineStyle
    
    public init(object: JMTimelineObject,
                style: JMTimelineStyle) {
        self.object = object
        self.style = style
    }
}

public typealias JMTimelineItemZoneProvider = (JMTimelineItem) -> UIView

public class JMTimelineItem: Equatable, Hashable {
    public let UUID: String
    public let date: Date
    public let object: JMTimelineObject
    public let style: JMTimelineStyle
    public let zones: [JMTimelineItemZoneProvider]
    public let extra: JMTimelineExtraOptions
    public let countable: Bool
    public let cachable: Bool
    private(set) var renderOptions: JMTimelineRenderOptions
    private(set) weak var provider: JMTimelineProvider!
    private(set) weak var interactor: JMTimelineInteractor!

    public init(UUID: String,
                date: Date,
                object: JMTimelineObject,
                style: JMTimelineStyle,
                zones: [JMTimelineItemZoneProvider] = Array(),
                extra: JMTimelineExtraOptions,
                countable: Bool,
                cachable: Bool,
                provider: JMTimelineProvider,
                interactor: JMTimelineInteractor) {
        self.UUID = UUID
        self.date = date
        self.object = object
        self.style = style
        self.zones = zones
        self.extra = extra
        self.countable = countable
        self.cachable = cachable
        self.renderOptions = .allOptions
        self.provider = provider
        self.interactor = interactor
    }

    var groupingID: String? {
        return UUID
    }
    
    var interactiveID: String? {
        return nil
    }
    
    public var hashValue: Int {
        return UUID.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(UUID)
    }

    final func addRenderOptions(_ options: JMTimelineRenderOptions) {
        renderOptions.formUnion(options)
    }
    
    public final func hasRenderOptions(_ options: JMTimelineRenderOptions) -> Bool {
        return renderOptions.contains(options)
    }
    
    final func removeRenderOptions(_ options: JMTimelineRenderOptions) {
        renderOptions.subtract(options)
    }
    
    func equal(to another: JMTimelineItem) -> Bool {
        guard UUID == another.UUID else { return false }
        return true
    }
    
    public static func ==(lhs: JMTimelineItem, rhs: JMTimelineItem) -> Bool {
        return lhs.equal(to: rhs)
    }
}

extension JMTimelineItem {
    func convert<T>(to: T.Type) -> T {
        return self as! T
    }
}
