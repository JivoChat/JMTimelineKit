//
//  JMTimelineCallItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 27/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit

public struct JMTimelineMessageConferenceInfo: JMTimelineInfo {
    let repic: JMRepicItem?
    let caption: String
    let button: String?
    let url: URL?
    
    public init(repic: JMRepicItem?,
                caption: String,
                button: String?,
                url: URL?) {
        self.repic = repic
        self.caption = caption
        self.button = button
        self.url = url
    }
}

public struct JMTimelineConferenceStyle: JMTimelineStyle {
    let captionColor: UIColor
    let captionFont: UIFont
    let buttonBackground: UIColor
    let buttonForeground: UIColor
    let buttonFont: UIFont

    public init(captionColor: UIColor,
                captionFont: UIFont,
                buttonBackground: UIColor,
                buttonForeground: UIColor,
                buttonFont: UIFont) {
        self.captionColor = captionColor
        self.captionFont = captionFont
        self.buttonBackground = buttonBackground
        self.buttonForeground = buttonForeground
        self.buttonFont = buttonFont
    }
}

public class JMTimelineMessageConferenceItem: JMTimelineMessageItem {
}
