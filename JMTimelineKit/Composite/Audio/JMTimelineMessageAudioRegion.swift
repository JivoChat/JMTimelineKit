//
//  JMTimelineMessageAudioRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

extension JMTimelineTrigger {
    static let audioTap = JMTimelineTrigger()
}

public final class JMTimelineMessageAudioRegion: JMTimelineMessageCanvasRegion {
    private let audioBlock = JMTimelineCompositeAudioBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .inline))
        integrateBlocks([audioBlock], gap: 0)
        
        audioBlock.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageAudioInfo {
            audioBlock.configure(
                item: info.URL,
                duration: info.duration)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineCompositeAudioStyle.self)
//
//        audioBlock.apply(style: contentStyle)
//    }
    
    @objc private func handleTap() {
        guard let info = currentInfo as? JMTimelineMessageAudioInfo else {
            return
        }
        
        triggerHander?(.audioTap(info.URL))
    }
}
