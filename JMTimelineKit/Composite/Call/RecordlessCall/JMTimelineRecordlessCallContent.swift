//
//  JMTimelineRecordlessCallContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineRecordlessCallContent: JMTimelineCompositeContent {
    private let stateBlock = JMTimelineCompositeHeadingBlock(height: 18)
    private let recordlessBlock = JMTimelineCompositeCallRecordlessBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [stateBlock, recordlessBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineCallStyle.self)

        stateBlock.apply(
            style: JMTimelineCompositeHeadingStyle(
                margin: 8,
                gap: 5,
                iconSize: CGSize(width: 18, height: 18),
                captionColor: contentStyle.stateColor,
                captionFont: contentStyle.stateFont)
        )
        
        recordlessBlock.apply(
            style: JMTimelineCompositeCallRecordlessStyle(
                phoneTextColor: contentStyle.phoneColor,
                phoneFont: contentStyle.phoneFont,
                phoneLinesLimit: contentStyle.phoneLinesLimit
            )
        )
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineCallItem.self)
        let object = item.object.convert(to: JMTimelineCallObject.self)
        
        stateBlock.link(provider: item.provider, interactor: item.interactor)
        stateBlock.configure(repic: object.repic, repicTint: nil, state: object.state)
        
        recordlessBlock.link(provider: item.provider, interactor: item.interactor)
        recordlessBlock.configure(phone: object.phone)
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
