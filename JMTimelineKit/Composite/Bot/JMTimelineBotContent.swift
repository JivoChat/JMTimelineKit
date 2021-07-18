//
//  JMTimelineBotContent.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 06.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineBotContent: JMTimelineCompositeContent {
    private let plainBlock = JMTimelineCompositePlainBlock()
    private let buttonsBlock = JMTimelineCompositeButtonsBlock(behavior: .horizontal)

    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [plainBlock, buttonsBlock]
        childrenGap = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineBotItem.self)
        let object = item.object.convert(to: JMTimelineBotObject.self)

        plainBlock.link(provider: item.provider, interactor: item.interactor)
        plainBlock.configure(content: object.text)
        plainBlock.render()
        
        buttonsBlock.configure(captions: object.buttons, tappable: object.tappable)
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineBotStyle.self)
        
        plainBlock.apply(style: contentStyle.plainStyle)
        buttonsBlock.apply(style: contentStyle.buttonsStyle)
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
