//
//  JMTimelineTimepointContent.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 21.07.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final public class JMTimelineTimepointContent: JMTimelineCanvas {
    private let captionLabel = JMTimelineTimepointLabel()
    private let leftLine = UIView()
    private let rightLine = UIView()
    
    private var margins = UIEdgeInsets.zero
    private var borderWidth = CGFloat(0)
    private var borderRadius: CGFloat?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(captionLabel)
        addSubview(leftLine)
        addSubview(rightLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(item: JMTimelineItem) {
        super.configure(item: item)
        
        if let item = item as? JMTimelineTimepointItem {
            captionLabel.text = item.payload.caption
            captionLabel.numberOfLines = 0
        }
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineTimepointStyle.self)
//        margins = style.margins
//        borderWidth = style.borderWidth
//        borderRadius = style.borderRadius
//
//        captionLabel.font = style.font
//        captionLabel.textColor = style.textColor
//        captionLabel.textAlignment = style.alignment
//        captionLabel.padding = style.padding
//
//        leftLine.backgroundColor = style.borderColor
//
//        rightLine.backgroundColor = style.borderColor
//    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        captionLabel.frame = layout.captionLabelFrame
        captionLabel.layer.cornerRadius = layout.captionLabelBorderRadius
        leftLine.frame = layout.leftLineFrame
        rightLine.frame = layout.rightLineFrame
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            captionLabel: captionLabel,
            margins: margins,
            borderWidth: borderWidth,
            borderRadius: borderRadius)
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let captionLabel: UILabel
    let margins: UIEdgeInsets
    let borderWidth: CGFloat
    let borderRadius: CGFloat?

    var captionLabelFrame: CGRect {
        let size = captionLabelSize
        let width = size.width
        let height = size.height
        
        switch captionLabel.textAlignment {
        case .left: return CGRect(x: margins.left, y: 0, width: width, height: height)
        case .right: return CGRect(x: bounds.width - width - margins.right, y: 0, width: width, height: height)
        case .center: return CGRect(x: (bounds.width - width) * 0.5, y: 0, width: width, height: height)
        case .natural: return CGRect(x: margins.left, y: 0, width: bounds.width - margins.horizontal, height: height)
        case .justified: return CGRect(x: margins.left, y: 0, width: bounds.width - margins.horizontal, height: height)
        @unknown default: return CGRect(x: margins.left, y: 0, width: bounds.width - margins.horizontal, height: height)
        }
    }
    
    var captionLabelBorderRadius: CGFloat {
        return borderRadius ?? captionLabelFrame.height * 0.5
    }
    
    var leftLineFrame: CGRect {
        let anchorFrame = captionLabelFrame
        let topY = anchorFrame.midY - borderWidth * 0.5
        let width = anchorFrame.minX - margins.left
        return CGRect(x: margins.left, y: topY, width: width, height: borderWidth)
    }
    
    var rightLineFrame: CGRect {
        let anchorFrame = captionLabelFrame
        let topY = anchorFrame.midY - borderWidth * 0.5
        let leftX = anchorFrame.maxX
        let width = bounds.width - leftX - margins.right
        return CGRect(x: leftX, y: topY, width: width, height: borderWidth)
    }

    var totalSize: CGSize {
        let size = captionLabelSize
        let height = size.height + margins.vertical
        return CGSize(width: bounds.width, height: height)
    }
    
    private var captionLabelSize: CGSize {
        let width = bounds.width - margins.horizontal
        return captionLabel.size(for: width)
    }
}
