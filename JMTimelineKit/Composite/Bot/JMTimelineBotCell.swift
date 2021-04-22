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

final class JMTimelineBotCell: JMTimelineCompositeCell, ModelTransfer {
    private let internalContent = JMTimelineBotContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineBotItem) {
        container.configure(item: model)
    }
}

