//
//  JMTimelineEmojiCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineEmojiCell: JMTimelineCompositeCell, ModelTransfer {
    private let internalContent = JMTimelineEmojiContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineEmojiItem) {
        container.configure(item: model)
    }
}
