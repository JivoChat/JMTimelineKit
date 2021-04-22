//
//  JMTimelineCompositeMediaBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMScalableView

public struct JMTimelineCompositeMediaStyle: JMTimelineStyle {
    let iconBackground: UIColor
    let iconTintColor: UIColor
    let iconSide: CGFloat
    let iconCategory: UIFont.TextStyle
    let titleColor: UIColor
    let titleFont: UIFont
    let titleLinesLimit: Int
    let subtitleColor: UIColor
    let subtitleFont: UIFont
    
    public init(iconBackground: UIColor,
                iconTintColor: UIColor,
                iconSide: CGFloat,
                iconCategory: UIFont.TextStyle,
                titleColor: UIColor,
                titleFont: UIFont,
                titleLinesLimit: Int,
                subtitleColor: UIColor,
                subtitleFont: UIFont) {
        self.iconBackground = iconBackground
        self.iconTintColor = iconTintColor
        self.iconSide = iconSide
        self.iconCategory = iconCategory
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleLinesLimit = titleLinesLimit
        self.subtitleColor = subtitleColor
        self.subtitleFont = subtitleFont
    }
}

final class JMTimelineCompositeMediaBlock: UIView, JMTimelineBlock {
    private let iconUnderlay = UIView()
    private let iconView = JMScalableView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private var interactor: JMTimelineInteractor!
    private var url: URL?
    private var style: JMTimelineCompositeMediaStyle!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconUnderlay)
        
        iconView.category = UIFont.TextStyle.title1
        iconView.clipsToBounds = true
        addSubview(iconView)
        
        titleLabel.lineBreakMode = .byTruncatingMiddle
        addSubview(titleLabel)
        
        subtitleLabel.numberOfLines = 0
        addSubview(subtitleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        self.interactor = interactor
    }
    
    func configure(icon: UIImage?, url: URL?, title: String?, subtitle: String?) {
        self.url = url
        iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = title ?? url?.lastPathComponent
        subtitleLabel.text = subtitle
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeMediaStyle.self)
        self.style = style
        
        iconUnderlay.backgroundColor = style.iconBackground
        iconView.backgroundColor = style.iconBackground
        iconView.tintColor = style.iconTintColor
        titleLabel.textColor = style.titleColor
        titleLabel.font = style.titleFont
        titleLabel.numberOfLines = style.titleLinesLimit
        subtitleLabel.textColor = style.subtitleColor
        subtitleLabel.font = style.subtitleFont
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
        iconUnderlay.frame = layout.iconUnderlayFrame
        iconUnderlay.layer.cornerRadius = layout.iconUnderlayCornerRadius
        iconView.frame = layout.iconViewFrame
        iconView.layer.cornerRadius = layout.iconViewCornerRadius
        titleLabel.frame = layout.titleLabelFrame
        subtitleLabel.frame = layout.subsitleLabelFrame
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        apply(style: style)
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            titleLabel: titleLabel,
            subtitleLabel: subtitleLabel,
            style: style
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    let style: JMTimelineCompositeMediaStyle
    
    private let underlayMargin = CGFloat(7)
    
    var iconUnderlayFrame: CGRect {
        return iconViewFrame.insetBy(dx: -underlayMargin, dy: -underlayMargin)
    }
    
    var iconUnderlayCornerRadius: CGFloat {
        return iconUnderlayFrame.width * 0.5
    }
    
    var iconViewFrame: CGRect {
        let side = style.iconSide.scaled(category: style.iconCategory)
        return CGRect(x: underlayMargin, y: underlayMargin, width: side, height: side)
    }
    
    var iconViewCornerRadius: CGFloat {
        return iconViewFrame.width * 0.5
    }
    
    var titleLabelFrame: CGRect {
        let leftX = iconUnderlayFrame.maxX + 10
        let width = bounds.width - leftX
        let height = titleLabel.calculateHeight(for: width)
        return CGRect(x: leftX, y: 0, width: width, height: height)
    }
    
    var subsitleLabelFrame: CGRect {
        let topY = titleLabelFrame.maxY + 5
        let leftX = titleLabelFrame.minX
        let width = bounds.width - leftX
        let height = subtitleLabel.calculateHeight(for: width)
        return CGRect(x: leftX, y: topY, width: width, height: height)
    }
    
    var totalSize: CGSize {
        let labelsRightX = max(titleLabelFrame.maxX, subsitleLabelFrame.maxX)
        let labelsBottomY = subtitleLabel.hasText ? subsitleLabelFrame.maxY : titleLabelFrame.maxY
        
        return CGSize(
            width: min(bounds.width, labelsRightX),
            height: max(iconUnderlayFrame.maxY, labelsBottomY)
        )
    }
}
