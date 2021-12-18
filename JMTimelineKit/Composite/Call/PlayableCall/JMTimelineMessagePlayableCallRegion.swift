//
//  JMTimelineMessagePlayableCallRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessagePlayableCallRegion: JMTimelineMessageCanvasRegion {
    private let stateBlock = JMTimelineCompositeHeadingBlock(height: 18)
    private let playableBlock = JMTimelineCompositeCallPlayableBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([stateBlock, playableBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageCallInfo {
            stateBlock.configure(
                repic: info.repic,
                repicTint: nil,
                state: info.state)
            
            if let mediaPlayerItem = info.recordURL {
                playableBlock.configure(
                    phone: info.phone,
                    item: mediaPlayerItem,
                    duration: info.duration)
            }
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineCallStyle.self)
//
//        stateBlock.apply(
//            style: JMTimelineCompositeHeadingStyle(
//                margin: 8,
//                gap: 5,
//                iconSize: CGSize(width: 18, height: 18),
//                captionColor: contentStyle.stateColor,
//                captionFont: contentStyle.stateFont)
//        )
//
//        playableBlock.apply(
//            style: JMTimelineCompositeCallPlayableStyle(
//                controlBorderColor: contentStyle.playControlBorderColor,
//                controlTintColor: contentStyle.playControlTintColor,
//                controlSide: contentStyle.playControlSide,
//                controlCategory: contentStyle.playControlCategory,
//                sliderThumbSide: contentStyle.sliderThumbSide,
//                sliderThumbColor: contentStyle.sliderThumbColor,
//                sliderMinColor: contentStyle.sliderMinColor,
//                sliderMaxColor: contentStyle.sliderMaxColor,
//                phoneTextColor: contentStyle.phoneColor,
//                phoneFont: contentStyle.phoneFont,
//                phoneLinesLimit: contentStyle.phoneLinesLimit,
//                durationTextColor: contentStyle.durationColor,
//                durationFont: contentStyle.durationFont
//            )
//        )
//    }
}
