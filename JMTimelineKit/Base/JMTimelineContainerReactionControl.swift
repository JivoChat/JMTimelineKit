//
//  JMTimelineContainerReactionControl.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 07.05.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit

fileprivate final class ElementContainer: UIView {
    private let element: IBaseElement & UIView
    
    init(element: IBaseElement & UIView) {
        self.element = element
        
        super.init(frame: .zero)
        
        addSubview(element)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return element.sizeThatFits(size)
    }
    
    override var intrinsicContentSize: CGSize {
        let parentalSize = CGSize(width: .infinity, height: element.height)
        return element.sizeThatFits(parentalSize)
    }
    
    override func layoutSubviews() {
        let padding = (bounds.height - element.height) * 0.5
        element.frame = bounds.insetBy(dx: 0, dy: padding)
    }
}

protocol IBaseElement {
    var height: CGFloat { get set }
}

public final class JMTimelineContainerReactionControl: UIView {
    var shortTapHandler: (() -> Void)?
    var longTapHandler: (() -> Void)?

    private let stackView = UIStackView()
    private var emojiElement: CaptionElement?
    private var emojiElementContainer: ElementContainer?
    private var counterElement: CaptionElement?
    private var counterElementContainer: ElementContainer?
    private var actionElement: IconElement?
    private var actionElementContainer: ElementContainer?
    private var style: JMTimelineReactionStyle?
    private var isSelected = false

    public init(reaction meta: JMTimelineReactionMeta) {
        isSelected = meta.participated
        
        super.init(frame: .zero)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        
        let emojiElement = CaptionElement()
        emojiElement.text = meta.emoji
        let emojiElementContainer = ElementContainer(element: emojiElement)
        stackView.addArrangedSubview(emojiElementContainer)
        self.emojiElement = emojiElement
        self.emojiElementContainer = emojiElementContainer
        
        let counterElement = CaptionElement()
        counterElement.text = "\(meta.number)"
        let counterElementContainer = ElementContainer(element: counterElement)
        stackView.addArrangedSubview(counterElementContainer)
        self.counterElement = counterElement
        self.counterElementContainer = counterElementContainer

        configureGestures()
    }
    
    public init(action meta: JMTimelineActionMeta) {
        isSelected = false
        
        super.init(frame: .zero)
        
//        renderingButton.setImage(meta.icon, for: .normal)
//        renderingButton.isUserInteractionEnabled = false
//        addSubview(renderingButton)
//
//        calculatingButton.setTitle("😀", for: .normal)
//        calculatingButton.isUserInteractionEnabled = false
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        addSubview(stackView)
        
        let actionElement = IconElement()
        actionElement.image = meta.icon
        actionElement.contentMode = .scaleAspectFit
        let actionElementContainer = ElementContainer(element: actionElement)
        stackView.addArrangedSubview(actionElementContainer)
        self.actionElement = actionElement
        self.actionElementContainer = actionElementContainer

        configureGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func apply(style: JMTimelineReactionStyle) {
        self.style = style
        
        emojiElement?.font = style.baseFont
        emojiElement?.fontReducer = style.emojiElement.fontReducer
        emojiElement?.fontPullingCoef = style.emojiElement.pullingCoef
        
        counterElement?.font = style.baseFont
        counterElement?.fontReducer = style.counterElement.fontReducer
        counterElement?.fontPullingCoef = style.counterElement.pullingCoef

        if isSelected {
            backgroundColor = style.selectedBackgroundColor
            counterElement?.textColor = style.selectedNumberColor
        }
        else {
            backgroundColor = style.regularBackgroundColor
            counterElement?.textColor = style.regularNumberColor
        }
    }
    
    private func configureGestures() {
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleShortTap))
        )
        
        addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        )
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let style = applyConfiguration() {
            let elements = [emojiElement, counterElement, actionElement].compactMap { $0 }
            let width = (style.height * style.sidePaddingCoef * 2) + (CGFloat(elements.count) * stackView.spacing)
                + (emojiElementContainer?.sizeThatFits(.zero) ?? .zero).width
                + (counterElementContainer?.sizeThatFits(.zero) ?? .zero).width
                + (actionElementContainer?.sizeThatFits(.zero) ?? .zero).width
            
            return CGSize(width: width, height: style.height)
        }
        else {
            return .zero
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let style = applyConfiguration() {
            let side = style.height * style.sidePaddingCoef
            stackView.frame = bounds.insetBy(dx: side, dy: 0)
        }
        
        layer.cornerRadius = bounds.height * 0.5
        layer.masksToBounds = true
    }
    
    private func applyConfiguration() -> JMTimelineReactionStyle? {
        guard let style = style else { return nil }
        emojiElement?.height = style.height * (1.0 - style.emojiElement.paddingCoef * 2)
        counterElement?.height = style.height * (1.0 - style.counterElement.paddingCoef * 2)
        actionElement?.height = style.height * (1.0 - style.actionElement.paddingCoef * 2)
        return style
    }
    
    @objc private func handleShortTap() {
        shortTapHandler?()
    }
    
    @objc private func handleLongTap(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        longTapHandler?()
    }
}

fileprivate final class CaptionElement: UIView, IBaseElement {
    var height = CGFloat(0)
    var text = String()
    var minText = String()
    var textColor = UIColor.black
    var font = UIFont.systemFont(ofSize: 10)
    var fontReducer = CGFloat(0)
    var fontPullingCoef = CGFloat(0)
    
    init() {
        super.init(frame: .zero)
        
        isOpaque = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let parentalSize = CGSize(width: .infinity, height: height)
        let width = richContent(text).boundingRect(with: parentalSize, options: [], context: nil).width
        let minimalWidth = richContent("0").boundingRect(with: parentalSize, options: [], context: nil).width
        return CGSize(width: max(minimalWidth, width), height: height)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.clear(rect)
        richContent(text).draw(at: CGPoint(x: 0, y: font.lineHeight * fontPullingCoef))
    }
    
    private func richContent(_ value: String) -> NSAttributedString {
        return NSAttributedString(
            string: value,
            attributes: [.foregroundColor: textColor, .font: font.withSize(height - fontReducer)])
    }
}

fileprivate final class IconElement: UIImageView, IBaseElement {
    var height = CGFloat(0)
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: height, height: height)
    }
}
