//
//  JMTimelineFinishedConferenceCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineFinishedConferenceCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelineFinishedConferenceContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineFinishedConferenceItem) {
        container.configure(item: model)
    }
}
