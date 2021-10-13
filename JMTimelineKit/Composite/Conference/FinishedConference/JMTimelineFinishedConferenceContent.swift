//
//  JMTimelineFinishedConferenceContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineFinishedConferenceContent: JMTimelineCompositeContent {
    private let captionBlock = JMTimelineCompositeHeadingBlock(height: 40)
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [captionBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineConferenceStyle.self)

        captionBlock.apply(
            style: JMTimelineCompositeHeadingStyle(
                margin: 8,
                gap: 12,
                iconSize: CGSize(width: 40, height: 40),
                captionColor: contentStyle.captionColor,
                captionFont: contentStyle.captionFont)
        )
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineConferenceItem.self)
        let object = item.object.convert(to: JMTimelineConferenceObject.self)
        
        captionBlock.link(provider: item.provider, interactor: item.interactor)
        captionBlock.configure(repic: object.repic, repicTint: nil, state: object.caption)
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
