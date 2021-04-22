//
//  JMTimelinePhotoContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelinePhotoContent: JMTimelineCompositeContent {
    private let imageBlock = JMTimelineCompositePhotoBlock()
    
    public init() {
        super.init(renderMode: .contentBehindTime)
        children = [imageBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelinePhotoStyle.self)
        
        imageBlock.waitingIndicatorStyle = contentStyle.waitingIndicatorStyle
        
        imageBlock.apply(
            style: JMTimelineCompositePhotoStyle(
                ratio: contentStyle.ratio,
                contentMode: contentStyle.contentMode
            )
        )
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelinePhotoItem.self)
        let object = item.object.convert(to: JMTimelinePhotoObject.self)
        let meta = object.scaleMeta(minimum: 60, maximum: 220)
        
        imageBlock.link(provider: item.provider, interactor: item.interactor)
        imageBlock.configure(url: object.url, originalSize: meta.size, cropped: meta.cropped, allowFullscreen: object.allowFullscreen)
    }
    
    override func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        switch super.handleLongPressInteraction(gesture: gesture) {
        case .incorrect: return .incorrect
        case .handled: return .handled
        case .unhandled where gesture.state == .began: break
        case .unhandled: return .handled
        }
        
        item?.interactor.constructMenuForMessage()
        
        return .handled
    }
}
