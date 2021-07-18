//
//  JMTimelineTaskContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineTaskContent: JMTimelineCompositeContent {
    private let taskBlock = JMTimelineCompositeTaskBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTime)
        children = [taskBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineItem.self)
        let object = item.object.convert(to: JMTimelineTaskObject.self)

        taskBlock.link(provider: item.provider, interactor: item.interactor)
        taskBlock.configure(icon: object.icon, brief: object.brief, agentRepicItem: object.agentRepic, agentName: object.agentName, date: object.date)
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineTaskStyle.self)
        
        taskBlock.apply(
            style: JMTimelineCompositeTaskStyle(
                briefLabelColor: contentStyle.briefLabelColor,
                briefLabelFont: contentStyle.briefLabelFont,
                agentNameColor: contentStyle.agentNameColor,
                agentNameFont: contentStyle.agentNameFont,
                dateColor: contentStyle.dateColor,
                dateFont: contentStyle.dateFont
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
