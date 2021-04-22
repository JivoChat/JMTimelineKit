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
    let ID: String
    let icon: JMRepicItem?
    let name: String?
    
    public init(ID: String,
                icon: JMRepicItem?,
                name: String?) {
        self.ID = ID
        self.icon = icon
        self.name = name
    }
}

public class JMTimelineMessageItem: JMTimelineItem {
    let status: String?
    let delivery: JMTimelineItemDelivery
    let position: JMTimelineItemPosition
    let sender: JMTimelineItemSender
    let isExclusive: Bool
    let needsMeta: Bool
    
    public init(UUID: String,
                date: Date,
                object: JMTimelineObject,
                status: String?,
                delivery: JMTimelineItemDelivery,
                position: JMTimelineItemPosition,
                sender: JMTimelineItemSender,
                style: JMTimelineStyle,
                extra: JMTimelineExtraOptions,
                countable: Bool,
                cachable: Bool,
                isExclusive: Bool,
                needsMeta: Bool,
                provider: JMTimelineProvider,
                interactor: JMTimelineInteractor) {
        self.status = status
        self.delivery = delivery
        self.position = position
        self.sender = sender
        self.isExclusive = isExclusive
        self.needsMeta = needsMeta
        
        super.init(
            UUID: UUID,
            date: date,
            object: object,
            style: style,
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
