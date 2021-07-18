//
//  JMTimelineOrderContent.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 25.09.2020.
//

import Foundation
import DTModelStorage

public final class JMTimelineOrderContent: JMTimelineCompositeContent {
    private let headingBlock = JMTimelineCompositeHeadingBlock(height: 40)
    private let detailsBlock = JMTimelineCompositePlainBlock()
    private let buttonsBlock = JMTimelineCompositeButtonsBlock(behavior: .vertical)
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        
        children = [headingBlock, detailsBlock, buttonsBlock]
        childrenGap = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineOrderItem.self)
        let object = item.object.convert(to: JMTimelineOrderObject.self)
        
        headingBlock.link(provider: item.provider, interactor: item.interactor)
        headingBlock.configure(repic: object.repic, repicTint: object.repicTint, state: object.subject)
        
        detailsBlock.link(provider: item.provider, interactor: item.interactor)
        detailsBlock.configure(content: object.text)
        detailsBlock.render()
        
        buttonsBlock.link(provider: item.provider, interactor: item.interactor)
        buttonsBlock.configure(captions: [object.button], tappable: true)
        
        buttonsBlock.tapHandler = { _ in
            guard let phone = object.phone else { return }
            item.interactor.callForOrder(phone: phone)
        }
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineOrderStyle.self)
        
        headingBlock.apply(
            style: JMTimelineCompositeHeadingStyle(
                margin: 0,
                gap: 8,
                iconSize: CGSize(width: 48, height: 48),
                captionColor: contentStyle.headingCaptionColor,
                captionFont: contentStyle.headingCaptionFont)
        )
        
        detailsBlock.apply(
            style: JMTimelineCompositePlainStyle(
                textColor: contentStyle.detailsColor,
                identityColor: contentStyle.contactsColor,
                linkColor: contentStyle.contactsColor,
                font: contentStyle.detailsFont,
                boldFont: nil,
                italicsFont: nil,
                strikeFont: nil,
                lineHeight: 20,
                alignment: .left,
                underlineStyle: nil,
                parseMarkdown: false)
        )
        
        buttonsBlock.apply(
            style: contentStyle.actionButton
        )
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
