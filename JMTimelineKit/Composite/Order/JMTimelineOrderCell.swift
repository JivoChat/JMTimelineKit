//
//  JMTimelineOrderCell.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 25.09.2020.
//

import Foundation
import UIKit
import DTModelStorage

final class JMTimelineOrderCell: JMTimelineMultiCell, ModelTransfer {
    private let internalContent = JMTimelineOrderContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelineOrderItem) {
        container.configure(item: model)
    }
}

