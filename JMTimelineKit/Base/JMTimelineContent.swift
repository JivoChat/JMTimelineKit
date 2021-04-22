//
//  JMTimelineContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

@objc enum JMTimelineContentInteractionResult: Int {
    case incorrect
    case handled
    case unhandled
}

public class JMTimelineContent: UIView, JMTimelineStylable {
    private(set) var item: JMTimelineItem?
    private(set) var style: JMTimelineStyle?
    
    public func configure(item: JMTimelineItem) {
        self.item = item
        setNeedsLayout()
    }
    
    public func apply(style: JMTimelineStyle) {
        self.style = style
    }
    
    func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        guard let uuid = item?.UUID else { return .incorrect }
        if let item = self.item {
            item.interactor.tapHandler?(item, .long)
        }
        JMTimelineStoreUUID(uuid)
        return .unhandled
    }
}
