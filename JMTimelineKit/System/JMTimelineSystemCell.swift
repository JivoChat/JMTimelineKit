//
//  JMTimelineSystemCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage
import JMRepicKit

final class JMTimelineSystemCell: JMTimelineEventCell, ModelTransfer {
    let internalContent = JMTimelineSystemContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineSystemItem) {
        container.configure(item: model)
    }
}
