//
//  JMTimelineMessageRichRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes
import DTModelStorage

public final class JMTimelineMessageRichRegion: JMTimelineMessageCanvasRegion {
    private let richBlock = JMTimelineCompositeRichBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([richBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageRichInfo {
            richBlock.configure(rich: info.content)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineRichStyle.self)
//
//        richBlock.apply(style: contentStyle)
//    }
}
