//
//  JMTimelinePlayableCallContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelinePlayableCallContent: JMTimelineCompositeContent {
    private let stateBlock = JMTimelineCompositeHeadingBlock(height: 18)
    private let playableBlock = JMTimelineCompositeCallPlayableBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [stateBlock, playableBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelinePlayableCallItem.self)
        let object = item.object.convert(to: JMTimelineCallObject.self)
        let mediaPlayerItem = object.recordURL
        
        stateBlock.link(provider: item.provider, interactor: item.interactor)
        stateBlock.configure(repic: object.repic, repicTint: nil, state: object.state)
        
        if let mediaPlayerItem = mediaPlayerItem {
            playableBlock.link(provider: item.provider, interactor: item.interactor)
            playableBlock.configure(phone: object.phone, item: mediaPlayerItem, duration: object.duration)
        }
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
        
        playableBlock.apply(
            style: JMTimelineCompositeCallPlayableStyle(
                controlBorderColor: contentStyle.playControlBorderColor,
                controlTintColor: contentStyle.playControlTintColor,
                controlSide: contentStyle.playControlSide,
                controlCategory: contentStyle.playControlCategory,
                sliderThumbSide: contentStyle.sliderThumbSide,
                sliderThumbColor: contentStyle.sliderThumbColor,
                sliderMinColor: contentStyle.sliderMinColor,
                sliderMaxColor: contentStyle.sliderMaxColor,
                phoneTextColor: contentStyle.phoneColor,
                phoneFont: contentStyle.phoneFont,
                phoneLinesLimit: contentStyle.phoneLinesLimit,
                durationTextColor: contentStyle.durationColor,
                durationFont: contentStyle.durationFont
            )
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
