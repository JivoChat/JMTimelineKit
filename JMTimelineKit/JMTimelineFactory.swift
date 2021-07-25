//
//  JMTimelineFactory.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 01/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JFCollectionViewManager

open class JMTimelineFactory {
    public init() {
    }
    
    func register(manager: DTCollectionViewManager) {
        manager.registerNiblessFooter(JMTimelineDateHeaderView.self)
        manager.registerNibless(JMTimelineLoaderCell.self)
        manager.registerNibless(JMTimelineSystemCell.self)
        manager.registerNibless(JMTimelineTimepointCell.self)
        manager.registerNibless(JMTimelinePlainCell.self)
        manager.registerNibless(JMTimelineBotCell.self)
        manager.registerNibless(JMTimelineOrderCell.self)
        manager.registerNibless(JMTimelineEmojiCell.self)
        manager.registerNibless(JMTimelinePhotoCell.self)
        manager.registerNibless(JMTimelineMediaCell.self)
        manager.registerNibless(JMTimelineEmailCell.self)
        manager.registerNibless(JMTimelineLocationCell.self)
        manager.registerNibless(JMTimelinePlayableCallCell.self)
        manager.registerNibless(JMTimelineRecordlessCallCell.self)
        manager.registerNibless(JMTimelineRichCell.self)
        manager.registerNibless(JMTimelineTaskCell.self)
        manager.registerNibless(JMTimelineUniCell.self)
    }
    
    open func generateDateItem(date: Date) -> JMTimelineItem {
        abort()
    }
    
    open func generateContent(for item: JMTimelineItem) -> JMTimelineContent {
        abort()
    }
}

