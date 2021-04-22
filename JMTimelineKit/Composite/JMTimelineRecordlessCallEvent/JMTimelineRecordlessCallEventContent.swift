//
//  JMTimelineRecordlessCallEventContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelineRecordlessCallEventContent: JMTimelineCompositeEventContent {
    private let callBlock = JMTimelineCompositeEventCallStatusBlock()
    private let lessBlock = JMTimelineCompositeEventCallRecordlessBlock()
    
    init() {
        super.init(renderMode: .bubbleWithTime)
        children = [callBlock, lessBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        guard let message = item.message, message.isValid else { return }
        guard let call = message.call else { return }
        
        callBlock.configure(
            type: call.type,
            status: call.status,
            isMissed: call.isMissed
        )
        
        lessBlock.formattingProvider = formattingProvider
        lessBlock.interactingContext = interactingContext
        
        lessBlock.configure(phone: call.phone)
    }
    
    override func adjustStyle(for item: JMTimelineItem) {
        super.adjustStyle(for: item)
        
        guard let message = item.message, message.isValid else { return }
        
        callBlock.textColor = DesignBook.shared.color(.black)
        lessBlock.textColor = DesignBook.shared.color(.steel)
    }
}
