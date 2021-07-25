//
//  JMTimelinePhotoCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import DTModelStorage

final class JMTimelinePhotoCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelinePhotoContent()
    
    override func obtainContent() -> JMTimelinePhotoContent {
        return internalContent
    }
    
    func update(with model: JMTimelinePhotoItem) {
        container.configure(item: model)
    }
}
