//
//  JMTimelineCompositeButtonsBlock.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 06.08.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes
import JMMarkdownKit

public enum JMTimelineCompositeButtonsBehavior {
    case horizontal
    case vertical
}

public struct JMTimelineCompositeButtonsStyle: JMTimelineStyle {
    let backgroundColor: UIColor
    let captionColor: UIColor
    let captionFont: UIFont
    let captionPadding: UIEdgeInsets
    let buttonGap: CGFloat
    let cornerRadius: CGFloat

    public init(backgroundColor: UIColor,
                captionColor: UIColor,
                captionFont: UIFont,
                captionPadding: UIEdgeInsets,
                buttonGap: CGFloat,
                cornerRadius: CGFloat) {
        self.backgroundColor = backgroundColor
        self.captionColor = captionColor
        self.captionFont = captionFont
        self.captionPadding = captionPadding
        self.buttonGap = buttonGap
        self.cornerRadius = cornerRadius
    }
}

final class JMTimelineCompositeButtonsBlock: UIView, JMTimelineBlock {
    private let behavior: JMTimelineCompositeButtonsBehavior
    
    var tapHandler: ((Int) -> Void)?
    
    private var buttons = [UIButton]()
    private var captionPadding = UIEdgeInsets.zero
    private var buttonGap = CGFloat(0)

    init(behavior: JMTimelineCompositeButtonsBehavior) {
        self.behavior = behavior
        
        super.init(frame: .zero)
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
    }
    
    func configure(captions: [String], tappable: Bool) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons = captions.map { caption in
            let button = UIButton()
            button.setTitle(caption, for: .normal)
            button.isUserInteractionEnabled = tappable
            button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
            return button
        }
        buttons.forEach { addSubview($0) }
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeButtonsStyle.self)
        captionPadding = style.captionPadding
        buttonGap = style.buttonGap
        
        for button in buttons {
            button.setBackgroundImage(UIImage(color: style.backgroundColor), for: .normal)
            button.setTitleColor(style.captionColor, for: .normal)
            button.titleLabel?.font = style.captionFont
            button.titleEdgeInsets = style.captionPadding
            button.layer.cornerRadius = style.cornerRadius
            button.layer.masksToBounds = true
        }
        
        setNeedsLayout()
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return true
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override func layoutSubviews() {
        let layout = getLayout(size: bounds.size)
        zip(buttons, layout.buttonFrames).forEach { $0.frame = $1 }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            behavior: behavior,
            buttons: buttons,
            captionPadding: captionPadding,
            buttonGap: buttonGap)
    }
    
    @objc private func handleButtonTap(_ button: UIButton) {
        guard let index = buttons.firstIndex(of: button) else { return }
        tapHandler?(index)
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let behavior: JMTimelineCompositeButtonsBehavior
    let buttons: [UIButton]
    let captionPadding: UIEdgeInsets
    let buttonGap: CGFloat
    
    var buttonFrames: [CGRect] {
        var rect = CGRect.zero
        return buttons.map { button in
            let size = normalize(
                buttonSize: button.sizeThatFits(.zero).extendedBy(insets: button.titleEdgeInsets)
            )
            
            defer {
                rect.origin.x = rect.maxX + buttonGap
            }
            
            if rect.maxX + size.width <= bounds.width {
                rect.size = size
                return rect
            }
            else {
                rect.origin.x = 0
                rect.origin.y += rect.height + buttonGap
                rect.size = size
                return rect
            }
        }
    }
    
    var totalSize: CGSize {
        let height = buttonFrames.last?.maxY ?? 0
        return CGSize(width: bounds.width, height: height)
    }
    
    private func normalize(buttonSize size: CGSize) -> CGSize {
        switch behavior {
        case .horizontal: return size
        case .vertical: return CGSize(width: bounds.width, height: size.height)
        }
    }
}
