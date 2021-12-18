//
//  JMTimelineOrderContent.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 25.09.2020.
//

import Foundation
import DTModelStorage

extension JMTimelineTrigger {
    static let orderPhoneCall = JMTimelineTrigger()
}

public final class JMTimelineMessageOrderRegion: JMTimelineMessageCanvasRegion {
    private let headingBlock = JMTimelineCompositeHeadingBlock(height: 40)
    private let detailsBlock = JMTimelineCompositePlainBlock()
    private let buttonsBlock = JMTimelineCompositeButtonsBlock(behavior: .vertical)
    
    public init() {
        super.init(renderMode: .bubble(time: .compact))
        integrateBlocks([headingBlock, detailsBlock, buttonsBlock], gap: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        super.setup(info: info, meta: meta, options: options)
        
        if let info = info as? JMTimelineMessageOrderInfo {
            headingBlock.configure(
                repic: info.repic,
                repicTint: info.repicTint,
                state: info.subject)
            
            detailsBlock.configure(content: info.text)
            detailsBlock.render()
            
            buttonsBlock.configure(
                captions: [info.button],
                tappable: true)
            
            buttonsBlock.tapHandler = { [weak self] _ in
                guard let phone = info.phone else { return }
                self?.triggerHander?(.orderPhoneCall(phone))
            }
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//        let contentStyle = style.contentStyle.convert(to: JMTimelineOrderStyle.self)
//
//        headingBlock.apply(
//            style: JMTimelineCompositeHeadingStyle(
//                margin: 0,
//                gap: 8,
//                iconSize: CGSize(width: 48, height: 48),
//                captionColor: contentStyle.headingCaptionColor,
//                captionFont: contentStyle.headingCaptionFont)
//        )
//
//        detailsBlock.apply(
//            style: JMTimelineCompositePlainStyle(
//                textColor: contentStyle.detailsColor,
//                identityColor: contentStyle.contactsColor,
//                linkColor: contentStyle.contactsColor,
//                font: contentStyle.detailsFont,
//                boldFont: nil,
//                italicsFont: nil,
//                strikeFont: nil,
//                lineHeight: 20,
//                alignment: .left,
//                underlineStyle: nil,
//                parseMarkdown: false)
//        )
//
//        buttonsBlock.apply(
//            style: contentStyle.actionButton
//        )
//    }
}
