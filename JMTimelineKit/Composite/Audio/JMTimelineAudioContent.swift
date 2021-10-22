//
//  JMTimelineAudioContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineAudioContent: JMTimelineCompositeContent {
    private let audioBlock = JMTimelineCompositeAudioBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTimeClosely)
        children = [audioBlock]
        
        audioBlock.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineCompositeAudioStyle.self)

        audioBlock.apply(style: contentStyle)
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        guard
            let object = item.object as? JMTimelineAudioObject
        else {
            return
        }
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        let icon = UIImage(named: "media_audio", in: Bundle.framework, compatibleWith: nil)
        let url = object.URL
        let title = object.title
        let subtitle = object.duration.flatMap(formatter.string)
        
        audioBlock.link(provider: item.provider, interactor: item.interactor)
        audioBlock.configure(item: object.URL, duration: object.duration)
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

    @objc private func handleTap() {
        guard
            let object = item?.object as? JMTimelineAudioObject
        else {
            return
        }
        
        item?.interactor.requestAudio(url: object.URL, mime: nil)
    }
}
