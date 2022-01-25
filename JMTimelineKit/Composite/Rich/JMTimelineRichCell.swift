//
//  JMTimelineRichCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineRichCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelineRichContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineRichItem) {
        container.configure(item: model)
    }
}