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

final class JMTimelinePlainCell: JMTimelineEventCell, ModelTransfer {
    private let internalCanvas = JMTimelineMessagePlainCanvas()
    
    override func obtainCanvas() -> JMTimelineCanvas {
        return internalCanvas
    }
    
    func update(with model: JMTimelineMessagePlainItem) {
        container.configure(item: model)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

