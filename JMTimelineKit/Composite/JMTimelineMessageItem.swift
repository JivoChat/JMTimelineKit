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

public struct JMTimelineMessagePayload {
    let kindID: String
    let sender: JMTimelineItemSender
    let renderOptions: JMTimelineMessageRenderOptions
    let contentGenerator: () -> [JMTimelineMessageCanvasRegion]
    let contentPopulator: ([JMTimelineMessageCanvasRegion]) -> Void
    
    public init(
            kindID: String,
            sender: JMTimelineItemSender,
            renderOptions: JMTimelineMessageRenderOptions,
            regionsGenerator: @escaping () -> [JMTimelineMessageCanvasRegion],
            regionsPopulator: @escaping ([JMTimelineMessageCanvasRegion]) -> Void
    ) {
        self.kindID = kindID
        self.sender = sender
        self.renderOptions = renderOptions
        self.contentGenerator = regionsGenerator
        self.contentPopulator = regionsPopulator
    }
}

public class JMTimelineMessageItem: JMTimelinePayloadItem<JMTimelineMessagePayload> {
    override var groupingID: String? {
        return payload.sender.ID
    }
}

public struct JMTimelineMessageItemSub {
    public let position: JMTimelineItemPosition
    public let renderOptions: JMTimelineRenderOptions
    public let delivery: JMTimelineItemDelivery
    public let status: String?
    
    public init(
        position: JMTimelineItemPosition,
        renderOptions: JMTimelineRenderOptions,
        delivery: JMTimelineItemDelivery,
        status: String?
    ) {
        self.position = position
        self.renderOptions = renderOptions
        self.delivery = delivery
        self.status = status
    }
}
