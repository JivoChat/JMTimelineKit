//
//  JMTimelineFinishedConferenceRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineFinishedConferenceRegion: JMTimelineMessageCanvasRegion {
    private let captionBlock = JMTimelineCompositeHeadingBlock(height: 40)
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([captionBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineConferenceStyle.self)
//
//        captionBlock.apply(
//            style: JMTimelineCompositeHeadingStyle(
//                margin: 8,
//                gap: 12,
//                iconSize: CGSize(width: 40, height: 40),
//                captionColor: contentStyle.captionColor,
//                captionFont: contentStyle.captionFont)
//        )
//    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageConferenceInfo {
            captionBlock.configure(
                repic: info.repic,
                repicTint: nil,
                state: info.caption)
        }
    }
}
