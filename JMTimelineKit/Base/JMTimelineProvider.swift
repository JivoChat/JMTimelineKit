//
//  JMTimelineProvider.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JMMarkdownKit
import Lottie

public enum JMTimelineResource {
    case raw(Data)
    case lottie(Animation)
    case nothing
}

public protocol JMTimelineProvider: class {
    func formattedDateForGroupHeader(_ date: Date) -> String
    func formattedDateForMessageEvent(_ date: Date) -> String
    func formattedTimeForPlayback(_ timestamp: TimeInterval) -> String
    func formattedPhoneNumber(_ phone: String) -> String
    func mentionProvider(origin: JMMarkdownMentionOrigin) -> JMMarkdownMentionMeta?
    func retrieveResource(from url: URL, canvasWidth: CGFloat, completion: @escaping (JMTimelineResource?) -> Void)
}
