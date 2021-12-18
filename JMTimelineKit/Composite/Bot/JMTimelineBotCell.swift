//
//  JMTimelineBotCell.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 06.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final class JMTimelineBotCell: JMTimelineEventCell, ModelTransfer {
    private let internalCanvas = JMTimelineBotCanvas()
    
    override func obtainCanvas() -> JMTimelineCanvas {
        return internalCanvas
    }
    
    func update(with model: JMTimelineMessageBotItem) {
        container.configure(item: model)
    }
}

