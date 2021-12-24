//
//  JMTimelineCanvas.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

@objc public enum JMTimelineContentInteractionResult: Int {
    case incorrect
    case handled
    case unhandled
}

public struct JMTimelineTrigger: Equatable {
    public let uid: UUID
    public let payload: Any?

    public init(uid: UUID = UUID(), payload: Any? = nil) {
        self.uid = uid
        self.payload = payload
    }
    
    public func callAsFunction(_ payload: Any) -> JMTimelineTrigger {
        return JMTimelineTrigger(uid: uid, payload: payload)
    }
    
    public func extract<T>() -> T? {
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

open class JMTimelineCanvas: UIView {
    public private(set) var item: JMTimelineItem?

    open func configure(item: JMTimelineItem) {
        self.item = item
        setNeedsLayout()
    }
    
    open func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        return .unhandled
    }
}

open class JMTimelineLinkedCanvas<Provider, Interactor>: JMTimelineCanvas {
    private let provider: Provider
    private let interactor: Interactor
    
    public init(provider: Provider, interactor: Interactor) {
        self.provider = provider
        self.interactor = interactor
        
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
