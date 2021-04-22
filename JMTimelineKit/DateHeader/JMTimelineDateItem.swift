//
//  JMTimelineDateItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19/08/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public struct JMTimelineDateObject: JMTimelineObject {
    let date: Date
    
    public init(date: Date) {
        self.date = date
    }
}

public final class JMTimelineDateItem: JMTimelineItem {
}
