//
//  JMTimelineMessageEmojiItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import UIKit

public struct JMTimelineMessageEmojiInfo: JMTimelineInfo {
    let emoji: String
    
    public init(emoji: String) {
        self.emoji = emoji
    }
}

public typealias JMTimelineEmojiStyle = JMTimelineCompositeRichStyle

public final class JMTimelineMessageEmojiItem: JMTimelineMessageItem {
}
