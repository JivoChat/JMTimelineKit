//
//  JMTimelineMediaPlayerItem.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public enum JMTimelineMediaPlayerItemStatus {
    case none
    case loading
    case playing(current: TimeInterval, duration: TimeInterval)
    case paused(current: TimeInterval, duration: TimeInterval)
    case failed
}

public struct JMTimelineMediaPlayerState {
    let URL: URL
    let status: JMTimelineMediaPlayerItemStatus
    
    public init(URL: URL,
                status: JMTimelineMediaPlayerItemStatus) {
        self.URL = URL
        self.status = status
    }
}
