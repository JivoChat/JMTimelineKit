//
//  JMTimelinePlainCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final class JMTimelinePlainCell: JMTimelineCompositeCell, ModelTransfer {
    private let internalContent = JMTimelinePlainContent()
    
    override func obtainContent() -> JMTimelineContent {
        return internalContent
    }
    
    func update(with model: JMTimelinePlainItem) {
        container.configure(item: model)
    }
}

