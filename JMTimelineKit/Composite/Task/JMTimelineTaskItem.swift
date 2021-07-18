//
//  JMTimelineTaskItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import JMRepicKit

public struct JMTimelineTaskObject: JMTimelineObject {
    public let icon: UIImage?
    public let brief: String
    public let agentRepic: JMRepicItem?
    public let agentName: String
    public let date: String

    public init(
        icon: UIImage?,
        brief: String,
        agentRepic: JMRepicItem?,
        agentName: String,
        date: String
    ) {
        self.icon = icon
        self.brief = brief
        self.agentRepic = agentRepic
        self.agentName = agentName
        self.date = date
    }
}

public struct JMTimelineTaskStyle: JMTimelineStyle {
    let briefLabelColor: UIColor
    let briefLabelFont: UIFont
    let agentNameColor: UIColor
    let agentNameFont: UIFont
    let dateColor: UIColor
    let dateFont: UIFont
    
    public init(briefLabelColor: UIColor,
                briefLabelFont: UIFont,
                agentNameColor: UIColor,
                agentNameFont: UIFont,
                dateColor: UIColor,
                dateFont: UIFont) {
        self.briefLabelColor = briefLabelColor
        self.briefLabelFont = briefLabelFont
        self.agentNameColor = agentNameColor
        self.agentNameFont = agentNameFont
        self.dateColor = dateColor
        self.dateFont = dateFont
    }
}

public final class JMTimelineTaskItem: JMTimelineMessageItem {
}
