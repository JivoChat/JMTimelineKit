//
//  JMTimelineMessageEmojiRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessageEmojiRegion: JMTimelineMessageCanvasRegion {
    private let plainBlock = JMTimelineCompositePlainBlock()
    
    public init() {
        super.init(renderMode: .content(time: .near))
        integrateBlocks([plainBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageEmojiInfo {
            plainBlock.configure(content: info.emoji)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelinePlainStyle.self)
//
//        plainBlock.apply(style: contentStyle)
//    }
}
