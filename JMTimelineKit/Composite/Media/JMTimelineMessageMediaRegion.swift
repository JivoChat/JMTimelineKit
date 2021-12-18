//
//  JMTimelineMessageMediaRegion.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

extension JMTimelineTrigger {
    static let mediaTap = JMTimelineTrigger()
    static let mediaContactTap = JMTimelineTrigger()
}

struct JMTimelineMediaTriggerContactPayload: Hashable {
    let name: String
    let phone: String
}

public final class JMTimelineMessageMediaRegion: JMTimelineMessageCanvasRegion {
    private let mediaBlock = JMTimelineCompositeMediaBlock()
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([mediaBlock], gap: 0)
        
        mediaBlock.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMediaItem {
            let icon: UIImage?
            let url: URL?
            let title: String?
            let subtitle: String?
            
            switch info.payload {
            case let object as JMTimelineMediaVideoInfo:
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .positional
                formatter.allowedUnits = [.hour, .minute, .second]
                formatter.zeroFormattingBehavior = .pad
                
                icon = UIImage(named: "media_video", in: Bundle.framework, compatibleWith: nil)
                url = object.URL
                title = object.title
                subtitle = object.duration.flatMap(formatter.string)
                
            case let object as JMTimelineMediaDocumentInfo:
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useGB, .useMB, .useKB, .useBytes]
                formatter.countStyle = .binary
                formatter.allowsNonnumericFormatting = false
                
                icon = UIImage(named: "media_document", in: Bundle.framework, compatibleWith: nil)
                url = object.URL
                title = object.title
                subtitle = object.dataSize.flatMap(formatter.string)
                
            case let object as JMTimelineMediaContactInfo:
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
            
            mediaBlock.configure(
                icon: icon,
                url: url,
                title: title,
                subtitle: subtitle)
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineMediaStyle.self)
//
//        mediaBlock.apply(style: contentStyle)
//    }
    
    @objc private func handleTap() {
        guard let info = currentInfo as? JMTimelineMediaItem else {
            return
        }
        
        switch info.payload {
//        case let object as JMTimelineAudioObject:
//            item?.interactor.requestMedia(url: object.URL, mime: nil, completion: { _ in })
            
        case let object as JMTimelineMediaVideoInfo:
            triggerHander?(.mediaTap(object.URL))
            
        case let object as JMTimelineMediaDocumentInfo:
            triggerHander?(.mediaTap(object.URL))
            
//            item?.interactor.requestMedia(url: object.URL, mime: nil) { [weak self] status in
//                self?.mediaBlock.configure(withMediaStatus: status)
//            }

        case let object as JMTimelineMediaContactInfo:
            let payload = JMTimelineMediaTriggerContactPayload(
                name: object.name,
                phone: object.phone
            )
            
            triggerHander?(.mediaContactTap(payload))
            
        default:
            break
        }
    }
}
