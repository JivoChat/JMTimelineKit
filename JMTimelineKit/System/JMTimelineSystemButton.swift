//
//  JMTimelineSystemEventButton.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes

struct JMTimelineSystemButtonStyle: JMTimelineStyle {
    let backgroundColor: UIColor
    let textColor: UIColor
    let font: UIFont
    let margins: UIEdgeInsets
    let underlineStyle: NSUnderlineStyle
    let cornerRadius: CGFloat
}

final class JMTimelineSystemButton: UIButton, JMTimelineStylable {
    var tapHandler: (() -> Void)?
    
    private var style: JMTimelineSystemButtonStyle?
    
    init() {
        super.init(frame: .zero)
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            guard let style = style else { return }
            if style.cornerRadius == .infinity {
                layer.cornerRadius = bounds.height * 0.5
            }
            else {
                layer.cornerRadius = style.cornerRadius
            }
        }
    }
    
    var caption: String? {
        didSet {
            update(title: caption)
        }
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineSystemButtonStyle.self)
        self.style = style

        setBackgroundImage(UIImage(color: style.backgroundColor), for: .normal)
        setBackgroundImage(UIImage(color: style.backgroundColor), for: .highlighted)
        layer.masksToBounds = true
        
        update(title: caption)
    }
    
    private func update(title: String?) {
        guard let title = title else {
            super.setAttributedTitle(nil, for: .normal)
            return
        }
        
        guard let style = style else {
            super.setTitle(caption, for: .normal)
            return
        }
        
        super.setAttributedTitle(
            title.attributed(
                TextAttributes(minimumCapacity: 1)
                    .backgroundColor(style.backgroundColor)
                    .foregroundColor(style.textColor)
                    .font(style.font)
                    .underlineStyle(style.underlineStyle)
            ),
            for: .normal
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return calculateResultingSize(size)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return calculateResultingSize(size)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasAnotherStyle(than: previousTraitCollection), let style = style {
            setBackgroundImage(UIImage(color: style.backgroundColor), for: .normal)
            setBackgroundImage(UIImage(color: style.backgroundColor), for: .highlighted)
        }
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        preconditionFailure("Use .caption instead")
    }
    
    private func calculateResultingSize(_ size: CGSize) -> CGSize {
        let margins = style?.margins ?? .zero
        let extendedSize = size.extendedBy(insets: margins)
        return CGSize(width: extendedSize.width + extendedSize.height, height: extendedSize.height)
    }
    
    @objc private func handleTap() {
        tapHandler?()
    }
}
