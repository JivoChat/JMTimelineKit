//
//  JMTimelinePlainContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMessagePlainRegion: JMTimelineMessageCanvasRegion {
    private let plainBlock = JMTimelineCompositePlainBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([plainBlock], gap: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessagePlainInfo {
            plainBlock.configure(content: info.text)
        }
    }
}
