//
//  JMTimelineMessageBotRegion.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 06.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessageBotRegion: JMTimelineMessageCanvasRegion {
    private let plainBlock = JMTimelineCompositePlainBlock()
    private let buttonsBlock = JMTimelineCompositeButtonsBlock(behavior: .horizontal)

    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([plainBlock, buttonsBlock], gap: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageBotInfo {
            plainBlock.configure(content: info.text)
            plainBlock.render()
            
            buttonsBlock.configure(
                captions: info.buttons,
                tappable: info.tappable)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineBotStyle.self)
//
//        plainBlock.apply(style: contentStyle.plainStyle)
//        buttonsBlock.apply(style: contentStyle.buttonsStyle)
//    }
}
