//
//  JMTimelineEmailItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMMarkdownKit

public struct JMTimelineEmailObject: JMTimelineObject {
    let headers: [JMTimelineCompositePair]
    let message: String
    
    public init(headers: [JMTimelineCompositePair],
                message: String) {
        self.headers = headers
        self.message = message
    }
}

public struct JMTimelineEmailStyle: JMTimelineStyle {
    let headerColor: UIColor
    let headerFont: UIFont
    let messageColor: UIColor
    let identityColor: UIColor
    let linkColor: UIColor
    let messageFont: UIFont
    
    public init(headerColor: UIColor,
                headerFont: UIFont,
                messageColor: UIColor,
                identityColor: UIColor,
                linkColor: UIColor,
                messageFont: UIFont) {
        self.headerColor = headerColor
        self.headerFont = headerFont
        self.messageColor = messageColor
        self.identityColor = identityColor
        self.linkColor = linkColor
        self.messageFont = messageFont
    }
}

public final class JMTimelineEmailItem: JMTimelineMessageItem {
}
