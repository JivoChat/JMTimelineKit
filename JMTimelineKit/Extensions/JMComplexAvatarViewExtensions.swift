//
//  JMComplexAvatarViewExtensions.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 29/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import JMRepicKit

extension JMRepicView {
    class func standard(height: CGFloat = 75) -> JMRepicView {
        return JMRepicView(
            config: JMRepicConfig(
                side: height,
                borderWidth: 0,
                borderColor: .clear,
                itemConfig: JMRepicItemConfig(
                    borderWidthProvider: { _ in 0 },
                    borderColor: .clear
                ),
                layoutMap: [
                    1: [JMRepicLayoutItem(position: .zero, radius: 1.0)]
                ]
            )
        )
    }
}
