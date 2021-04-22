//
//  JMTimelineBotItem.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 06.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation

public struct JMTimelineBotObject: JMTimelineObject {
    let text: String
    let buttons: [String]
    let tappable: Bool

    public init(text: String, buttons: [String], tappable: Bool) {
        self.text = text
        self.buttons = buttons
        self.tappable = tappable
    }
}

public struct JMTimelineBotStyle: JMTimelineStyle {
    let plainStyle: JMTimelinePlainStyle
    let buttonsStyle: JMTimelineCompositeButtonsStyle

    public init(plainStyle: JMTimelinePlainStyle,
                buttonsStyle: JMTimelineCompositeButtonsStyle) {
        self.plainStyle = plainStyle
        self.buttonsStyle = buttonsStyle
    }
}

public final class JMTimelineBotItem: JMTimelineMessageItem {
}
