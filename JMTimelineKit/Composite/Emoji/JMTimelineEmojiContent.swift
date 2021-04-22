//
//  JMTimelineEmojiContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineEmojiContent: JMTimelineCompositeContent {
    private let plainBlock = JMTimelineCompositePlainBlock()
    
    public init() {
        super.init(renderMode: .contentAndTime)
        children = [plainBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineEmojiItem.self)
        let object = item.object.convert(to: JMTimelineEmojiObject.self)
        
        plainBlock.link(provider: item.provider, interactor: item.interactor)
        plainBlock.configure(content: object.emoji)
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelinePlainStyle.self)
        
        plainBlock.apply(style: contentStyle)
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
