//
//  JMTimelinePlainItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

public struct JMTimelinePlainObject: JMTimelineObject {
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}

public typealias JMTimelinePlainStyle = JMTimelineCompositePlainStyle

public final class JMTimelinePlainItem: JMTimelineMessageItem {
}
