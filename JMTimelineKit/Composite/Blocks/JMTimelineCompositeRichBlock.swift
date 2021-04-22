//
//  JMTimelineCompositeRichBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes

public struct JMTimelineCompositeRichStyle: JMTimelineStyle {
    public init() {
    }
}

final class JMTimelineCompositeRichBlock: UILabel, JMTimelineBlock {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
    }
    
    func configure(rich: NSAttributedString) {
        attributedText = rich
    }
    
    func apply(style: JMTimelineStyle) {
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
}
