//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit

public enum JMTimelineItemDelivery {
    case hidden
    case sent
    case delivered
    case seen
    case failed
}

public enum JMTimelineItemPosition {
    case left
    case right
}

public struct JMTimelineItemSender {
    public let ID: String
    public let icon: JMRepicItem?
    public let name: String?
    
    public init(ID: String,
                icon: JMRepicItem?,
                name: String?) {
        self.ID = ID
        self.icon = icon
        self.name = name
    }
}

public struct JMTimelineItemFlags: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let isExclusive = JMTimelineItemFlags(rawValue: 1 << 0)
    public static let needsMeta = JMTimelineItemFlags(rawValue: 1 << 1)
    public static let isQuote = JMTimelineItemFlags(rawValue: 1 << 2)
}

public class JMTimelineMessageItem: JMTimelineItem {
    let status: String?
    let delivery: JMTimelineItemDelivery
    let position: JMTimelineItemPosition
    let sender: JMTimelineItemSender
    public let flags: JMTimelineItemFlags
    
    public init(UUID: String,
                date: Date,
                object: JMTimelineObject,
                zones: [JMTimelineItemZoneProvider] = Array(),
                status: String?,
                delivery: JMTimelineItemDelivery,
                position: JMTimelineItemPosition,
                sender: JMTimelineItemSender,
                style: JMTimelineStyle,
                extra: JMTimelineExtraOptions,
                countable: Bool,
                cachable: Bool,
                flags: JMTimelineItemFlags,
                provider: JMTimelineProvider,
                interactor: JMTimelineInteractor) {
        self.status = status
        self.delivery = delivery
        self.position = position
        self.sender = sender
        self.flags = flags
        
        super.init(
            UUID: UUID,
            date: date,
            object: object,
            style: style,
            zones: zones,
            extra: extra,
            countable: countable,
            cachable: cachable,
            provider: provider,
            interactor: interactor
        )
    }

    override var groupingID: String? {
        return sender.ID
    }
}
