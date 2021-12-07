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

public struct JMTimelineRenderOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let useEntireCanvas = JMTimelineRenderOptions(rawValue: 1 << 0)
    public static let showStatusBar = JMTimelineRenderOptions(rawValue: 1 << 1)
    public static let showQuoteLine = JMTimelineRenderOptions(rawValue: 1 << 2)
}

public class JMTimelineMessageItem: JMTimelineItem {
    let status: String?
    let delivery: JMTimelineItemDelivery
    let position: JMTimelineItemPosition
    let sender: JMTimelineItemSender
    public let renderOptions: JMTimelineRenderOptions
    public let extraActions: JMTimelineExtraActions
    
    public init(UUID: String,
                date: Date,
                object: JMTimelineObject!,
                config: JMTimelineUniConfig? = nil,
                status: String?,
                delivery: JMTimelineItemDelivery,
                position: JMTimelineItemPosition,
                sender: JMTimelineItemSender,
                style: JMTimelineStyle,
                extraActions: JMTimelineExtraActions,
                logicOptions: JMTimelineLogicOptions,
                renderOptions: JMTimelineRenderOptions,
                provider: JMTimelineProvider,
                interactor: JMTimelineInteractor) {
        self.status = status
        self.delivery = delivery
        self.position = position
        self.sender = sender
        self.renderOptions = renderOptions
        self.extraActions = extraActions

        super.init(
            UUID: UUID,
            date: date,
            object: object,
            style: style,
            config: config,
            logicOptions: logicOptions,
            provider: provider,
            interactor: interactor
        )
    }

    override var groupingID: String? {
        return sender.ID
    }
}
