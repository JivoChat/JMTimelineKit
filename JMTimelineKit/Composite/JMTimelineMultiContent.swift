//
//  JMTimelineMultiContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit
import JMOnetimeCalculator

public class JMTimelineMultiContent: UIView, JMTimelineStylable {
    private var contents = [JMTimelineContent]()

    public func configure(items: [JMTimelineItem]) {
        assertionFailure()
    }
    
    public func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            contents: contents
        )
    }
    
}

fileprivate struct Layout {
    let bounds: CGRect
    let contents: [JMTimelineContent]
    
    var totalSize: CGSize {
        return .zero
    }
    
}
