//
//  JMTimelineEventCell.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 15/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

fileprivate var staticFocusedTimelineItemUUID: String?
func JMTimelineStoreUUID(_ uuid: String) { staticFocusedTimelineItemUUID = uuid }
func JMTimelineObtainUUID() -> String? { return staticFocusedTimelineItemUUID }

class JMTimelineEventCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    private(set) lazy var container: JMTimelineContainer = { obtainContainer() }()
    private let longPressGesture = UILongPressGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(container)
        
        longPressGesture.addTarget(self, action: #selector(handleLongPress))
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func obtainContent() -> JMTimelineContent {
        abort()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return container.sizeThatFits(size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        container.frame = contentView.bounds
    }
    
    fileprivate func obtainContainer() -> JMTimelineContainer {
        return JMTimelineContainer(content: obtainContent())
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        _ = container.content.handleLongPressInteraction(gesture: gesture)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === longPressGesture {
            return otherGestureRecognizer is UILongPressGestureRecognizer
        }
        else {
            return false
        }
    }
}
