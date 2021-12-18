//
//  JMTimelineBotCanvas.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 16.12.2021.
//

import Foundation
import UIKit

public class JMTimelineBotCanvas: JMTimelineSingleCanvas<JMTimelineMessageBotRegion> {
    public init() {
        super.init(region: JMTimelineMessageBotRegion())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(item: JMTimelineItem) {
        super.configure(item: item)
    }
}
