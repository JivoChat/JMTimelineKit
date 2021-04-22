//
//  JMTimelinePlayableCallEventContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

final class JMTimelinePlayableCallEventContent: JMTimelineCompositeEventContent {
    private let callBlock = JMTimelineCompositeEventCallStatusBlock()
    private let playBlock = JMTimelineCompositeEventCallPlayableBlock()
    
    init() {
        super.init(renderMode: .bubbleWithTime)
        children = [callBlock, playBlock]
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
        
        playBlock.interactingContext = interactingContext
        playBlock.formattingProvider = formattingProvider
        
        if let url = call.recordURL {
            let item = MediaPlayerItem(url: url)
            playBlock.configure(phone: call.phone, item: item)
        }
    }
    
    override func adjustStyle(for item: JMTimelineItem) {
        super.adjustStyle(for: item)
        
        guard let message = item.message, message.isValid else { return }
        
        callBlock.textColor = DesignBook.shared.color(.black)
        playBlock.textColor = DesignBook.shared.color(.steel)
        playBlock.seecondaryTextColor = DesignBook.shared.color(.black).withAlpha(0.6)
    }
}
