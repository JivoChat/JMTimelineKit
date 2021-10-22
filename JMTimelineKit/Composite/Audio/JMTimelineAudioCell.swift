//
//  JMTimelineAudioCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineAudioCell: JMTimelineCompositeCell, ModelTransfer {
    private let internalContent = JMTimelineAudioContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineAudioItem) {
        container.configure(item: model)
    }
}
