//
//  JMTimelineCompositePairsBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineCompositePair {
    let caption: String
    let value: String
    
    public init(caption: String,
                value: String) {
        self.caption = caption
        self.value = value
    }
}

public struct JMTimelineCompositePairsStyle: JMTimelineStyle {
    let textColor: UIColor
    let font: UIFont
    
    public init(textColor: UIColor,
                font: UIFont) {
        self.textColor = textColor
        self.font = font
    }
}

final class JMTimelineCompositePairsBlock: UIView, JMTimelineBlock {
    private var captionLabels = [UILabel]()
    private var valueLabels = [UILabel]()
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
    }
    
    func configure(headers: [JMTimelineCompositePair]) {
        captionLabels.forEach { $0.removeFromSuperview() }
        valueLabels.forEach { $0.removeFromSuperview() }
        
        captionLabels = headers.map { header in
            let label = UILabel()
            label.text = header.caption
            return label
        }
        
        valueLabels = headers.map { header in
            let label = UILabel()
            label.text = header.value
            label.lineBreakMode = .byTruncatingTail
            return label
        }
        
        captionLabels.forEach { addSubview($0) }
        valueLabels.forEach { addSubview($0) }
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositePairsStyle.self)
        
        (captionLabels + valueLabels).forEach { label in
            label.textColor = style.textColor
            label.font = style.font
        }
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        zip(captionLabels, layout.captionLabelsFrames).forEach { $0.frame = $1 }
        zip(valueLabels, layout.valueLabelsFrames).forEach { $0.frame = $1 }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            captionLabels: captionLabels,
            valueLabels: valueLabels
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let captionLabels: [UILabel]
    let valueLabels: [UILabel]
    
    var captionLabelsFrames: [CGRect] {
        var rect = CGRect.zero
        return captionLabels.map { label in
            rect = rect.offsetBy(dx: 0, dy: rect.height)
            rect.size = label.size(for: bounds.width)
            return rect
        }
    }
    
    var valueLabelsFrames: [CGRect] {
        let maximalCaptionFrame = captionLabelsFrames.max { $0.maxX < $1.maxX }
        let leftX = (maximalCaptionFrame?.maxX ?? 0) + 10
        
        var rect = CGRect(x: leftX, y: 0, width: bounds.width - leftX, height: 0)
        return valueLabels.map { label in
            rect = rect.offsetBy(dx: 0, dy: rect.height)
            rect.size.height = label.size(for: bounds.width).height
            return rect
        }
    }
    
    var totalSize: CGSize {
        return CGSize(
            width: bounds.width,
            height: (captionLabelsFrames.last?.maxY ?? 0) + 10
        )
    }
}
