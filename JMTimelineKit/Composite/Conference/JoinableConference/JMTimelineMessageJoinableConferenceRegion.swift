//
//  JMTimelineMessageJoinableConferenceRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

extension JMTimelineTrigger {
    static let conferenceJoin = JMTimelineTrigger()
}

public final class JMTimelineMessageJoinableConferenceRegion: JMTimelineMessageCanvasRegion {
    private let captionBlock = JMTimelineCompositeHeadingBlock(height: 40)
    private let joinBlock = JMTimelineCompositeButtonsBlock(behavior: .vertical)
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([captionBlock, joinBlock], gap: 15)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageConferenceInfo {
            captionBlock.configure(
                repic: info.repic,
                repicTint: nil,
                state: info.caption)
            
            if let button = info.button {
                joinBlock.configure(
                    captions: [button],
                    tappable: true)
            }
            
            if let url = info.url {
                joinBlock.tapHandler = { [weak self] _ in
                    self?.triggerHander?(.conferenceJoin(url))
                }
            }
        }
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
//
//        joinBlock.apply(
//            style: JMTimelineCompositeButtonsStyle(
//                backgroundColor: contentStyle.buttonBackground,
//                captionColor: contentStyle.buttonForeground,
//                captionFont: contentStyle.buttonFont,
//                captionPadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
//                buttonGap: 0,
//                cornerRadius: 10
//            )
//        )
//    }
}
