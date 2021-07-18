//
//  JMTimelineRichContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes
import DTModelStorage

public final class JMTimelineRichContent: JMTimelineCompositeContent {
    private let richBlock = JMTimelineCompositeRichBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [richBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineRichItem.self)
        let object = item.object.convert(to: JMTimelineRichObject.self)

        richBlock.link(provider: item.provider, interactor: item.interactor)
        richBlock.configure(rich: object.content)
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineRichStyle.self)
        
        richBlock.apply(style: contentStyle)
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
