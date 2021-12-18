//
//  JMTimelineCanvas.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

@objc enum JMTimelineContentInteractionResult: Int {
    case incorrect
    case handled
    case unhandled
}

public struct JMTimelineTrigger: Equatable {
    let uid: UUID
    let payload: AnyHashable?

    public init(uid: UUID = UUID(), payload: AnyHashable? = nil) {
        self.uid = uid
        self.payload = payload
    }
    
    func callAsFunction(_ payload: AnyHashable) -> JMTimelineTrigger {
        return JMTimelineTrigger(uid: uid, payload: payload)
    }
    
    func extract<T: Hashable>() -> T? {
        return payload as? T
    }
    
    public static func == (lhs: JMTimelineTrigger, rhs: JMTimelineTrigger) -> Bool {
        guard lhs.uid == rhs.uid else { return false }
        return true
    }
}

public extension JMTimelineTrigger {
    static let prepareForMenu = JMTimelineTrigger()
    static let longPress = JMTimelineTrigger()
}

public class JMTimelineCanvas: UIView {
    private(set) var item: JMTimelineItem?
    
    public func configure(item: JMTimelineItem) {
        self.item = item
        setNeedsLayout()
    }
    
    func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        return .unhandled
    }
}
