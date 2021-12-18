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

public protocol JMTimelineMediaInfo {
}

public struct JMTimelineMediaVideoInfo: JMTimelineMediaInfo {
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

public struct JMTimelineMediaDocumentInfo: JMTimelineMediaInfo {
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

public struct JMTimelineMediaContactInfo: JMTimelineMediaInfo {
    let name: String
    let phone: String
    
    public init(name: String,
                phone: String) {
        self.name = name
        self.phone = phone
    }
}

public typealias JMTimelineMediaStyle = JMTimelineCompositeMediaStyle

public final class JMTimelineMediaItem: JMTimelinePayloadItem<JMTimelineMediaInfo> {
}
