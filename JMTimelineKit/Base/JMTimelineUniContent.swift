//
//  JMTimelineUniContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public final class JMTimelineUniContent: JMTimelineContent {
    private var zones = [UIView]()
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(item: JMTimelineItem) {
        zones.forEach { zone in zone.removeFromSuperview() }
        zones = item.zones.map { provider in provider(item) }
        zones.forEach { zone in addSubview(zone) }
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        zip(zones, layout.zonesFrames).forEach { zone, frm in zone.frame = frm }
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
    
    private func getLayout(size: CGSize) -> Layout {
        Layout(
            bounds: CGRect(origin: .zero, size: size),
            zones: zones
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let zones: [UIView]
    
    var zonesFrames: [CGRect] {
        var frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        return zones.map { zone in
            frame.origin.y += frame.size.height
            frame.size = zone.size(for: frame.width)
            return frame
        }
    }
    
    var totalSize: CGSize {
        let height = zonesFrames.last?.maxY ?? .zero
        return CGSize(width: bounds.width, height: height)
    }
}
