//
//  JMTimelineJoinableConferenceContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineJoinableConferenceContent: JMTimelineCompositeContent {
    private let captionBlock = JMTimelineCompositeHeadingBlock(height: 40)
    private let joinBlock = JMTimelineCompositeButtonsBlock(behavior: .vertical)
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [captionBlock, joinBlock]
        childrenGap = 15
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineJoinableConferenceItem.self)
        let object = item.object.convert(to: JMTimelineConferenceObject.self)
        
        captionBlock.link(provider: item.provider, interactor: item.interactor)
        captionBlock.configure(repic: object.repic, repicTint: nil, state: object.caption)
        
        if let button = object.button {
            joinBlock.link(provider: item.provider, interactor: item.interactor)
            joinBlock.configure(captions: [button], tappable: true)
        }
        
        if let url = object.url {
            joinBlock.tapHandler = { _ in item.interactor.joinConference(url: url) }
        }
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
        
        joinBlock.apply(
            style: JMTimelineCompositeButtonsStyle(
                backgroundColor: contentStyle.buttonBackground,
                captionColor: contentStyle.buttonForeground,
                captionFont: contentStyle.buttonFont,
                captionPadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                buttonGap: 0,
                cornerRadius: 10
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
