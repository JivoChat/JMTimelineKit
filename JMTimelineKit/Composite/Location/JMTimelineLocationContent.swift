//
//  JMTimelineLocationContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineLocationContent: JMTimelineCompositeContent {
    private let locationBlock = JMTimelineCompositeLocationBlock()
    
    public init() {
        super.init(renderMode: .contentBehindTime)
        children = [locationBlock]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineLocationItem.self)
        let object = item.object.convert(to: JMTimelineLocationObject.self)
        locationBlock.link(provider: item.provider, interactor: item.interactor)
        locationBlock.configure(coordinate: object.coordinate)
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineLocationStyle.self)
        locationBlock.apply(style: contentStyle)
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
