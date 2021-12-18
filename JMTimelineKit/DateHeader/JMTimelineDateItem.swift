//
//  JMTimelineDateItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 19/08/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public struct JMTimelineDateInfo: JMTimelineInfo {
    let caption: String
    
    public init(caption: String) {
        self.caption = caption
    }
}

public final class JMTimelineDateItem: JMTimelinePayloadItem<JMTimelineDateInfo> {
}
