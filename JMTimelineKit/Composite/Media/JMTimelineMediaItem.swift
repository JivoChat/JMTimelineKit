//
//  JMTimelineMediaItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public extension Notification.Name {
    static let JMMediaPlayerState = Notification.Name("JMMediaPlayerState")
}

public struct JMTimelineVideoObject: JMTimelineObject {
    let URL: URL
    let title: String?
    let duration: TimeInterval?
    
    public init(URL: URL,
                title: String?,
                duration: TimeInterval?) {
        self.URL = URL
        self.title = title
        self.duration = duration
    }
}

public struct JMTimelineDocumentObject: JMTimelineObject {
    public let URL: URL
    public let title: String?
    public let dataSize: Int64?
    
    public init(URL: URL,
                title: String?,
                dataSize: Int64?) {
        self.URL = URL
        self.title = title
        self.dataSize = dataSize
    }
}

public struct JMTimelineContactObject: JMTimelineObject {
    let name: String
    let phone: String
    
    public init(name: String,
                phone: String) {
        self.name = name
        self.phone = phone
    }
}

public typealias JMTimelineMediaStyle = JMTimelineCompositeMediaStyle

public final class JMTimelineMediaItem: JMTimelineMessageItem {
}
