//
//  JMTimelineEmailContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineEmailContent: JMTimelineCompositeContent {
    private let headersBlock = JMTimelineCompositePairsBlock()
    private let messageBlock = JMTimelineCompositePlainBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTime)
        children = [headersBlock, messageBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineEmailStyle.self)
        
        headersBlock.apply(
            style: JMTimelineCompositePairsStyle(
                textColor: contentStyle.headerColor,
                font: contentStyle.headerFont
            )
        )
        
        messageBlock.apply(
            style: JMTimelineCompositePlainStyle(
                textColor: contentStyle.messageColor,
                identityColor: contentStyle.identityColor,
                linkColor: contentStyle.linkColor,
                font: contentStyle.messageFont,
                boldFont: nil,
                italicsFont: nil,
                strikeFont: nil,
                lineHeight: 22,
                alignment: .natural,
                underlineStyle: nil,
                parseMarkdown: false)
        )
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineEmailItem.self)
        let object = item.object.convert(to: JMTimelineEmailObject.self)

        headersBlock.link(provider: item.provider, interactor: item.interactor)
        headersBlock.configure(headers: object.headers)
        
        messageBlock.link(provider: item.provider, interactor: item.interactor)
        messageBlock.configure(content: object.message)
        messageBlock.render()
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
