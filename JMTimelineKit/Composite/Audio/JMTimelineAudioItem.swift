//
//  JMTimelineAudioItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public extension Notification.Name {
    static let JMAudioPlayerState = Notification.Name("JMAudioPlayerState")
}

public struct JMTimelineAudioObject: JMTimelineObject {
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

public typealias JMTimelineAudioStyle = JMTimelineCompositeAudioStyle

public final class JMTimelineAudioItem: JMTimelineMessageItem {
}
