//
//  JMTimelineUniContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTModelStorage

public struct JMTimelineUniConfig {
    let configID: String
    let generator: () -> [JMTimelineCompositeContent]
    let populator: ([JMTimelineCompositeContent]) -> Void
    
    public init(
        configID: String,
        generator: @escaping () -> [JMTimelineCompositeContent],
        populator: @escaping ([JMTimelineCompositeContent]) -> Void
    ) {
        self.configID = configID
        self.generator = generator
        self.populator = populator
    }
}

public final class JMTimelineZone: UIView {
    public init(blocks: [UIView & JMTimelineBlock]) {
        super.init(frame: .zero)
        
        for block in blocks {
            addSubview(block)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = subviews.reduce(CGFloat.zero) { result, subview in
            result + subview.size(for: size.width).height
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var rect = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        subviews.forEach { subview in
            rect.origin.y += rect.height
            rect.size.height += subview.size(for: bounds.width).height
            subview.frame = rect
        }
    }
}

fileprivate var cachedZones = [String: Array<[JMTimelineCompositeContent]>]()

public final class JMTimelineUniContent: JMTimelineContent {
    private var configID = String()
    private var zones = [JMTimelineCompositeContent]()
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(item: JMTimelineItem) {
        guard let config = item.config else {
            return
        }
        
        if config.configID != configID {
            if !zones.isEmpty {
                let list = cachedZones[config.configID] ?? Array()
                cachedZones[config.configID] = list + [zones]
            }
            
            configID = config.configID
            
            zones.forEach { $0.removeFromSuperview() }
            defer {
                zones.forEach { addSubview($0) }
            }
            
            if var list = cachedZones[configID], !list.isEmpty {
                zones = list.removeFirst()
                cachedZones[configID] = list
            }
            else {
                zones = config.generator()
            }
        }
        
        config.populator(zones)
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
    
    private let gap = CGFloat(8)
    
    var zonesFrames: [CGRect] {
        var frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        return zones.map { zone in
            defer { frame.origin.y += gap }
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
