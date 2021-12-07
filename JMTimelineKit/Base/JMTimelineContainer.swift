//
//  JMTimelineContainer.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public final class JMTimelineContainer: UIView {
    let content: JMTimelineContent
    
    private var style: JMTimelineItemStyle!
    private var layoutOptions: JMTimelineLayoutOptions!

    public init(content: JMTimelineContent) {
        self.content = content
        
        super.init(frame: .zero)
        
        addSubview(content)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(item: JMTimelineItem) {
        style = item.style.convert(to: JMTimelineItemStyle.self)
        layoutOptions = item.layoutOptions

        content.configure(item: item)
        content.apply(style: style.contentStyle)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        content.frame = layout.contentFrame
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            content: content,
            style: style,
            layoutOptions: layoutOptions
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let content: JMTimelineContent
    let style: JMTimelineItemStyle
    let layoutOptions: JMTimelineLayoutOptions

    var contentFrame: CGRect {
        let width = bounds.reduceBy(insets: style.margins).width
        let height = content.size(for: width).height
        return CGRect(x: style.margins.left, y: calculatedTopMargin, width: width, height: height)
    }
    
    var totalSize: CGSize {
        let height = contentFrame.maxY + calculatedBottomMargin
        return CGSize(width: bounds.width, height: height)
    }
    
    private var calculatedTopMargin: CGFloat {
        let multiplier = layoutOptions.contains(.groupTopMargin) ? 1.0 : style.groupingCoef
        return style.margins.top * CGFloat(multiplier)
    }
    
    private var calculatedBottomMargin: CGFloat {
        let multiplier = layoutOptions.contains(.groupBottomMargin) ? 1.0 : style.groupingCoef
        return style.margins.bottom * CGFloat(multiplier)
    }
}
