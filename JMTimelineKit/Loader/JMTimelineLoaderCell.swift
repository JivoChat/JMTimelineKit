//
//  JMTimelineLoaderCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final class JMTimelineLoaderCell: JMTimelineEventCell, ModelTransfer {
    private let internalCanvas = JMTimelineLoaderContent()
    
    override func obtainCanvas() -> JMTimelineCanvas {
        return internalCanvas
    }
    
    func update(with model: JMTimelineLoaderItem) {
        container.configure(item: model)
    }
}
