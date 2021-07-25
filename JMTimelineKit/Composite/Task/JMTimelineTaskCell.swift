//
//  JMTimelineTaskCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final class JMTimelineTaskCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelineTaskContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineTaskItem) {
        container.configure(item: model)
    }
}

