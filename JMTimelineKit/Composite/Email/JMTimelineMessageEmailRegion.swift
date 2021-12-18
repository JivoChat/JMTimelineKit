//
//  JMTimelineMessageEmailRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessageEmailRegion: JMTimelineMessageCanvasRegion {
    private let headersBlock = JMTimelineCompositePairsBlock()
    private let messageBlock = JMTimelineCompositePlainBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([headersBlock, messageBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageEmailInfo {
            headersBlock.configure(headers: info.headers)
            
            messageBlock.configure(content: info.message)
            messageBlock.render()
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineEmailStyle.self)
//
//        headersBlock.apply(
//            style: JMTimelineCompositePairsStyle(
//                textColor: contentStyle.headerColor,
//                font: contentStyle.headerFont
//            )
//        )
//
//        messageBlock.apply(
//            style: JMTimelineCompositePlainStyle(
//                textColor: contentStyle.messageColor,
//                identityColor: contentStyle.identityColor,
//                linkColor: contentStyle.linkColor,
//                font: contentStyle.messageFont,
//                boldFont: nil,
//                italicsFont: nil,
//                strikeFont: nil,
//                lineHeight: 22,
//                alignment: .natural,
//                underlineStyle: .single,
//                parseMarkdown: true)
//        )
//    }
}
