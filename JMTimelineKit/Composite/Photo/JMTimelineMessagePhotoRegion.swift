//
//  JMTimelineMessagePhotoRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessagePhotoRegion: JMTimelineMessageCanvasRegion {
    private let imageBlock = JMTimelineCompositePhotoBlock()
    
    public init() {
        super.init(renderMode: .content(time: .over))
        integrateBlocks([imageBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessagePhotoInfo {
            let meta = info.scaleMeta(minimum: 60, maximum: 220)
            imageBlock.configure(
                url: info.url,
                originalSize: meta.size,
                cropped: meta.cropped,
                allowFullscreen: info.allowFullscreen)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelinePhotoStyle.self)
//
//        imageBlock.waitingIndicatorStyle = contentStyle.waitingIndicatorStyle
//
//        imageBlock.apply(
//            style: JMTimelineCompositePhotoStyle(
//                ratio: contentStyle.ratio,
//                contentMode: contentStyle.contentMode,
//                errorStubBackgroundColor: contentStyle.errorStubStyle.backgroundColor,
//                errorStubDescriptionColor: contentStyle.errorStubStyle.errorDescriptionColor
//            )
//        )
//    }
}
