//
//  JMTimelineMediaCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineMediaCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelineMediaContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineMediaItem) {
        container.configure(item: model)
    }
}
