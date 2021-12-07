//
//  JMTimelineObject.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 01/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public protocol JMTimelineObject {
}

public struct JMTimelineNoneObject: JMTimelineObject {
    public init() {
    }
}

extension JMTimelineObject {
    func convert<T>(to: T.Type) -> T {
        return self as! T
    }
}
