//
//  JMTimelineTimepointCell.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 21.07.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage
import JMRepicKit

final class JMTimelineTimepointCell: JMTimelineEventCell, ModelTransfer {
    let internalCanvas = JMTimelineTimepointContent()
    
    override func obtainCanvas() -> JMTimelineCanvas {
        return internalCanvas
    }
    
    func update(with model: JMTimelineTimepointItem) {
        container.configure(item: model)
    }
}
