//
//  JMTimelineMediaContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineMediaContent: JMTimelineCompositeContent {
    private let mediaBlock = JMTimelineCompositeMediaBlock()
    
    public init() {
        super.init(renderMode: .bubbleWithTimeNoGap)
        children = [mediaBlock]
        
        mediaBlock.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        let contentStyle = style.contentStyle.convert(to: JMTimelineMediaStyle.self)

        mediaBlock.apply(style: contentStyle)
    }
    
    override func populateBlocks(item: JMTimelineItem) {
        let icon: UIImage?
        let url: URL?
        let title: String?
        let subtitle: String?
        
        switch (item as! JMTimelineMediaItem).object {
        case let object as JMTimelineVideoObject:
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .positional
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.zeroFormattingBehavior = .pad
            
            icon = UIImage(named: "media_video", in: Bundle.framework, compatibleWith: nil)
            url = object.URL
            title = object.title
            subtitle = object.duration.flatMap(formatter.string)
            
        case let object as JMTimelineDocumentObject:
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useGB, .useMB, .useKB, .useBytes]
            formatter.countStyle = .binary
            formatter.allowsNonnumericFormatting = false
            
            icon = UIImage(named: "media_document", in: Bundle.framework, compatibleWith: nil)
            url = object.URL
            title = object.title
            subtitle = object.dataSize.flatMap(formatter.string)
            
        case let object as JMTimelineContactObject:
            icon = UIImage(named: "media_contact", in: Bundle.framework, compatibleWith: nil)
            url = nil
            title = object.name
            subtitle = object.phone
            
        default:
            assertionFailure()
            icon = nil
            url = nil
            title = nil
            subtitle = nil
        }
        
        mediaBlock.link(provider: item.provider, interactor: item.interactor)
        mediaBlock.configure(icon: icon, url: url, title: title, subtitle: subtitle)
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
        switch (item as! JMTimelineMediaItem).object {
        case let object as JMTimelineAudioObject:
            item?.interactor.requestMedia(url: object.URL, mime: nil, completion: { _ in })
            
        case let object as JMTimelineVideoObject:
            item?.interactor.requestMedia(url: object.URL, mime: nil, completion: { _ in })
            
        case let object as JMTimelineDocumentObject:
            item?.interactor.requestMedia(url: object.URL, mime: nil) { [weak self] status in
                self?.mediaBlock.configure(withMediaStatus: status)
            }

        case let object as JMTimelineContactObject:
            item?.interactor.addPerson(name: object.name, phone: object.phone)
            
        default:
            break
        }
    }
}
