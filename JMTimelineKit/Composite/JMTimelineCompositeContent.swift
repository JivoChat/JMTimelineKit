//
//  JMTimelineCompositeContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit
import JMOnetimeCalculator

public struct JMTimelineCompositeStyle: JMTimelineStyle {
    let senderBackground: UIColor
    let senderColor: UIColor
    let senderFont: UIFont
    let senderPadding: UIEdgeInsets
    let senderCorner: CGFloat
    let borderColor: UIColor?
    let borderWidth: CGFloat?
    let backgroundColor: UIColor?
    let foregroundColor: UIColor
    let statusColor: UIColor
    let statusFont: UIFont
    let timeRegularForegroundColor: UIColor
    let timeOverlayBackgroundColor: UIColor
    let timeOverlayForegroundColor: UIColor
    let timeFont: UIFont
    let deliveryViewTintColor: UIColor
    let reactionStyle: JMTimelineReactionStyle
    let contentStyle: JMTimelineStyle
    
    public init(senderBackground: UIColor,
                senderColor: UIColor,
                senderFont: UIFont,
                senderPadding: UIEdgeInsets,
                senderCorner: CGFloat,
                borderColor: UIColor?,
                borderWidth: CGFloat?,
                backgroundColor: UIColor?,
                foregroundColor: UIColor,
                statusColor: UIColor,
                statusFont: UIFont,
                timeRegularForegroundColor: UIColor,
                timeOverlayBackgroundColor: UIColor,
                timeOverlayForegroundColor: UIColor,
                timeFont: UIFont,
                deliveryViewTintColor: UIColor,
                reactionStyle: JMTimelineReactionStyle,
                contentStyle: JMTimelineStyle) {
        self.senderBackground = senderBackground
        self.senderColor = senderColor
        self.senderFont = senderFont
        self.senderPadding = senderPadding
        self.senderCorner = senderCorner
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.statusColor = statusColor
        self.statusFont = statusFont
        self.timeRegularForegroundColor = timeRegularForegroundColor
        self.timeOverlayBackgroundColor = timeOverlayBackgroundColor
        self.timeOverlayForegroundColor = timeOverlayForegroundColor
        self.timeFont = timeFont
        self.deliveryViewTintColor = deliveryViewTintColor
        self.reactionStyle = reactionStyle
        self.contentStyle = contentStyle
    }
}

enum JMTimelineCompositeRenderMode {
    case bubbleWithTime
    case contentAndTime
    case contentBehindTime
}

public class JMTimelineCompositeContent: JMTimelineContent {
    let senderIcon = JMRepicView.standard()
    let senderLabel = JMTimelineCompositeSenderLabel()
    let backgroundView = UIImageView()
    let statusLabel = UILabel()
    let timeLabel = UILabel()
    let deliveryView = JMTimelineDeliveryView()
    let footer = JMTimelineContainerFooter()

    private let renderMode: JMTimelineCompositeRenderMode
    
    init(renderMode: JMTimelineCompositeRenderMode) {
        self.renderMode = renderMode
        
        super.init(frame: .zero)
        
        addSubview(senderIcon)
        
        addSubview(senderLabel)
        
        backgroundView.layer.masksToBounds = true
        backgroundView.isUserInteractionEnabled = true
        addSubview(backgroundView)
        
        addSubview(statusLabel)
        
        timeLabel.layer.masksToBounds = true
        addSubview(timeLabel)
        
        deliveryView.contentMode = .right
        addSubview(deliveryView)
        
        addSubview(footer)
        
        senderIcon.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleSenderIconTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var children = [UIView & JMTimelineBlock]() {
        willSet {
            children.forEach { $0.removeFromSuperview() }
        }
        didSet {
            children.forEach { backgroundView.addSubview($0) }
        }
    }
    
    var childrenGap = CGFloat(0)
    
    var isEmpty: Bool {
        return children.isEmpty
    }
    
    public override func configure(item: JMTimelineItem) {
        super.configure(item: item)
        
        let item = item.convert(to: JMTimelineMessageItem.self)
        
        populateMeta(item: item)
        populateBlocks(item: item)
        
        if item.hasRenderOptions(.groupLastElement) {
            senderIcon.configure(item: item.sender.icon)
            senderIcon.isHidden = false
        }
        else {
            senderIcon.isHidden = true
        }
        
        footer.configure(reactions: item.extra.reactions, actions: item.extra.actions)
        
        footer.reactionHandler = { index in
            let reaction = item.extra.reactions[index]
            item.interactor.toggleMessageReaction(uuid: item.UUID, emoji: reaction.emoji)
        }
        
        footer.actionHandler = { index in
            let action = item.extra.actions[index]
            item.interactor.performMessageSubaction(uuid: item.UUID, actionID: action.ID)
        }
        
        footer.presentReactionsHandler = {
            item.interactor.presentMessageReactions(uuid: item.UUID)
        }
    }
    
    func populateBlocks(item: JMTimelineItem) {
        assertionFailure()
    }
    
    public override func apply(style: JMTimelineStyle) {
        super.apply(style: style)
        
        let style = style.convert(to: JMTimelineCompositeStyle.self)
        
        senderLabel.backgroundColor = style.senderBackground
        senderLabel.textColor = style.senderColor
        senderLabel.font = style.senderFont
        senderLabel.padding = style.senderPadding
        senderLabel.layer.cornerRadius = style.senderCorner
        senderLabel.layer.masksToBounds = true

        backgroundView.backgroundColor = nil
        backgroundView.image = style.backgroundColor.flatMap(getBackground)
        backgroundView.layer.borderColor = style.borderColor?.cgColor
        backgroundView.layer.borderWidth = style.borderWidth ?? 0
        
        statusLabel.textColor = style.statusColor
        statusLabel.font = style.statusFont
        
        deliveryView.tintColor = style.deliveryViewTintColor
        
        if renderMode == .contentBehindTime {
            timeLabel.backgroundColor = style.timeOverlayBackgroundColor
            timeLabel.textColor = style.timeOverlayForegroundColor
            timeLabel.font = style.timeFont
            timeLabel.textAlignment = .center
        }
        else {
            timeLabel.backgroundColor = UIColor.clear
            timeLabel.textColor = style.timeRegularForegroundColor
            timeLabel.font = style.timeFont
            timeLabel.textAlignment = .right
        }
        
        footer.apply(style: style.reactionStyle)
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        senderIcon.frame = layout.senderIconFrame
        senderLabel.frame = layout.senderLabelFrame
        senderLabel.textAlignment = layout.senderLabelAlignment
        backgroundView.frame = layout.backgroundViewFrame
        backgroundView.layer.cornerRadius = layout.backgroundViewCornerRadius
        statusLabel.frame = layout.statusLabelFrame
        timeLabel.frame = layout.timeLabelFrame
        timeLabel.layer.cornerRadius = layout.timeLabelCornerRadius
        deliveryView.frame = layout.deliveryViewFrame
        zip(children, layout.childrenFrames).forEach { $0.0.frame = $0.1 }
        footer.frame = layout.footerFrame
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let style = style?.convert(to: JMTimelineCompositeStyle.self) {
            backgroundView.image = style.backgroundColor.flatMap(getBackground)
        }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            item: item?.convert(to: JMTimelineMessageItem.self),
            senderLabel: senderLabel,
            statusLabel: statusLabel,
            timeLabel: timeLabel,
            deliveryView: deliveryView,
            children: children,
            childrenGap: childrenGap,
            footer: footer,
            renderMode: renderMode,
            renderOptions: item?.renderOptions ?? []
        )
    }
    
    private func populateMeta(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineMessageItem.self)
        
        if item.hasRenderOptions(.groupFirstElement) {
            senderLabel.text = item.sender.name
        }
        else {
            senderLabel.text = nil
        }
        
        if item.needsMeta {
            statusLabel.text = item.status
            timeLabel.text = item.provider.formattedDateForMessageEvent(item.date)
            deliveryView.configure(delivery: item.delivery)
        }
    }
    
    override func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        switch super.handleLongPressInteraction(gesture: gesture) {
        case .incorrect: return .incorrect
        case .handled: return .handled
        case .unhandled where gesture.state == .began: break
        case .unhandled: return .handled
        }
        
        if let item = item {
            if senderIcon.bounds.contains(gesture.location(in: senderIcon)) {
                item.interactor.senderIconLongPress(item: item)
            }
            else {
                for child in children {
                    guard child.bounds.contains(gesture.location(in: child)) else { continue }
                    guard child.handleLongPressGesture(recognizer: gesture) else { continue }
                    return .handled
                }
                
                if backgroundView.bounds.contains(gesture.location(in: backgroundView)) {
                    item.interactor.constructMenuForMessage()
                    return .handled
                }
            }
        }
        
        return .handled
    }
    
    @objc func handleSenderIconTap() {
        guard let item = item else { return }
        item.interactor.senderIconTap(item: item)
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let item: JMTimelineMessageItem?
    let senderLabel: UILabel
    let statusLabel: UILabel
    let timeLabel: UILabel
    let deliveryView: UIView
    let children: [UIView]
    let childrenGap: CGFloat
    let footer: JMTimelineContainerFooter
    let renderMode: JMTimelineCompositeRenderMode
    let renderOptions: JMTimelineRenderOptions
    
    private let sameGroupingGapCoef = CGFloat(0.2)
    private let iconSize = CGSize(width: 30, height: 30)
    private let iconGap = CGFloat(10)
    private let maximumWidthPercentage = CGFloat(0.93)
    private let gap = CGFloat(5)
    private let timeOuterGap = CGFloat(6)
    
    var senderIconFrame: CGRect {
        if !renderOptions.contains(.groupLastElement) {
            return .zero
        }
        
        if item?.sender.icon == nil {
            return .zero
        }
        
        let relativeFrame = backgroundViewFrame
        let topY = relativeFrame.maxY - iconSize.height
        return CGRect(x: 0, y: topY, width: iconSize.width, height: iconSize.height)
    }
    
    private let _senderLabelFrame = JMLazyEvaluator<Layout, CGRect> { s in
        let containerBounds = s.calculateHorizontalBounds()
        let containerWidth = s.bounds.width
        let size = s.senderLabel.size(for: containerWidth)
        
        if !s.renderOptions.contains(.groupFirstElement) {
            return .zero
        }
        
        if s.item?.sender.name == nil {
            return .zero
        }
        
        switch s.item?.position {
        case .left?:
            let leftX = containerBounds.origin
            return CGRect(x: leftX, y: 0, width: size.width, height: size.height)
        case .right?:
            let leftX = containerBounds.origin + containerBounds.width - size.width
            return CGRect(x: leftX, y: 0, width: size.width, height: size.height)
        case .none:
            return .zero
        }
    }
    
    var senderLabelFrame: CGRect {
        return _senderLabelFrame.value(input: self)
    }
    
    var senderLabelAlignment: NSTextAlignment {
        switch item?.position ?? .left {
        case .left: return .left
        case .right: return .right
        }
    }
    
    var backgroundViewFrame: CGRect {
        let horizontalBounds = calculateHorizontalBounds()
        let size = containerSize
        let leftX = horizontalBounds.origin
        
        if senderLabelFrame == .zero {
            return CGRect(x: leftX, y: 0, width: size.width, height: size.height)
        }
        else {
            let topY = senderLabelFrame.maxY + gap
            return CGRect(x: leftX, y: topY, width: size.width, height: size.height)
        }
    }
    
    var backgroundViewCornerRadius: CGFloat {
        switch renderMode {
        case .bubbleWithTime: return 8
        case .contentAndTime: return 0
        case .contentBehindTime: return 8
        }
    }
    
    var statusLabelFrame: CGRect {
        let horizontalBounds = calculateHorizontalBounds()
        let size = statusSize
        
        let leftX = horizontalBounds.origin + contentInsets.left
        let topY = timeLabelFrame.midY - size.height * 0.5
        return CGRect(x: leftX, y: topY, width: size.width, height: size.height)
    }
    
    var timeLabelFrame: CGRect {
        let horizontalBounds = calculateHorizontalBounds()
        let size = timeSize
        
        let leftX: CGFloat
        if renderMode == .contentAndTime {
            switch item?.position {
            case .left: leftX = horizontalBounds.origin + timeInsets.left
            case .right: leftX = horizontalBounds.origin + horizontalBounds.width - timeInsets.right - size.width
            case .none: leftX = 0
            }
        }
        else {
            leftX = horizontalBounds.origin + horizontalBounds.width - timeInsets.right - size.width
        }
        
        let topY = backgroundViewFrame.maxY - timeInsets.bottom - size.height
        return CGRect(x: leftX, y: topY, width: size.width, height: size.height)
    }
    
    var timeLabelCornerRadius: CGFloat {
        return timeLabelFrame.height * 0.5
    }
    
    var deliveryViewFrame: CGRect {
        let size = deliverySize
        let leftX = timeLabelFrame.minX - gap - size.width
        let topY = timeLabelFrame.midY - size.height * 0.5
        return CGRect(x: leftX, y: topY, width: size.width, height: size.height)
    }
    
    var childrenFrames: [CGRect] {
        var rect = CGRect(
            x: contentInsets.left,
            y: contentInsets.top - childrenGap,
            width: 0,
            height: 0)
        
        return childrenSizes.map { size in
            rect = rect.offsetBy(dx: 0, dy: rect.height + childrenGap)
            rect.size = size
            return rect
        }
    }
    
    var footerFrame: CGRect {
        let commonGap = iconSize.width + iconGap
        let size = footerSize
        
        let topY = backgroundViewFrame.maxY + 5
        let width = size.width
        let height = size.height
        
        switch item?.position {
        case .left?: return CGRect(x: commonGap, y: topY, width: width, height: height)
        case .right?: return CGRect(x: bounds.width - width, y: topY, width: width, height: height)
        case .none: return CGRect(x: commonGap, y: topY, width: width, height: height)
        }
    }
    
    var totalSize: CGSize {
        let senderHeight: CGFloat
        if let _ = senderLabel.text {
            senderHeight = senderLabelFrame.height + gap
        }
        else {
            senderHeight = 0
        }
        
        let timeHeight: CGFloat
        if let _ = timeLabel.text {
            timeHeight = timeSize.height + timeInsets.vertical
        }
        else {
            timeHeight = contentInsets.top - contentInsets.bottom
        }
        
        let baseHeight = senderHeight + childrenSize.height
        let contentInsetsHeight = (renderMode == .bubbleWithTime ? contentInsets.vertical : 0)
        let coveringMetaHeight = (renderMode != .contentBehindTime ? max(statusSize.height, timeHeight) : 0)
        
        let footerHeight: CGFloat
        if footerSize.height > 0 {
            footerHeight = footerSize.height + 6
        }
        else {
            footerHeight = 0
        }
        
        let height = baseHeight + contentInsetsHeight + coveringMetaHeight + footerHeight
        return CGSize(width: bounds.width, height: height)
    }
    
    private var maximumContainerWidth: CGFloat {
        let iconSpace = iconSize.width + iconGap
        return bounds.width * maximumWidthPercentage - iconSpace
    }
    
    private var maximumBlockWidth: CGFloat {
        if renderMode == .bubbleWithTime {
            return maximumContainerWidth - contentInsets.horizontal
        }
        else {
            return maximumContainerWidth
        }
    }
    
    private var contentInsets: UIEdgeInsets {
        switch renderMode {
        case .bubbleWithTime: return UIEdgeInsets(top: 14, left: 14, bottom: 0, right: 14)
        case .contentAndTime: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .contentBehindTime: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private var timeInsets: UIEdgeInsets {
        switch renderMode {
        case .bubbleWithTime: return UIEdgeInsets(top: 6, left: 6, bottom: 8, right: 8)
        case .contentAndTime: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .contentBehindTime: return UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2)
        }
    }
    
    private let _childrenSizes = JMLazyEvaluator<Layout, [CGSize]> { s in
        let widths: [CGFloat] = s.children.map { child in
            return child.size(for: s.maximumBlockWidth).width
        }
        
        let minimalWidth: CGFloat?
        if s.item?.isExclusive == true {
            minimalWidth = s.minimalContainerWidth
        }
        else {
            minimalWidth = nil
        }
        
        let maximumWidth: CGFloat
        if let minimalWidth = minimalWidth {
            maximumWidth = max(minimalWidth, widths.max() ?? 0)
        }
        else {
            maximumWidth = widths.max() ?? 0
        }
        
        return s.children.map { child in
            let height = child.size(for: maximumWidth).height
            return CGSize(width: maximumWidth, height: height)
        }
    }
    
    private var childrenSizes: [CGSize] {
        return _childrenSizes.value(input: self)
    }
    
    private var childrenSize: CGSize {
        let sizes = childrenSizes
        let gaps = childrenGap * CGFloat(sizes.count - 1)
        let maximumWidth = sizes.map({ $0.width }).max() ?? 0
        let totalHeight = sizes.map({ $0.height }).reduce(0, +) + gaps
        return CGSize(width: maximumWidth, height: totalHeight)
    }
    
    private let _containerSize = JMLazyEvaluator<Layout, CGSize> { s in
        let timeHeight: CGFloat
        if s.item?.isExclusive == true {
            timeHeight = 0
        }
        else if let _ = s.timeLabel.text {
            timeHeight = s.timeSize.height + s.timeInsets.vertical
        }
        else {
            timeHeight = s.contentInsets.top - s.contentInsets.bottom
        }
        
        let metaWidth = s.statusSize.width + s.gap + s.deliverySize.width + s.timeInsets.left + s.timeSize.width
        let contentWidth = max(s.childrenSize.width, metaWidth) + s.contentInsets.horizontal
        
        let baseHeight = s.childrenSize.height
        let contentInsetsHeight = (s.renderMode == .bubbleWithTime ? s.contentInsets.vertical : 0)
        let coveringTimeHeight = (s.renderMode != .contentBehindTime ? max(s.statusSize.height, timeHeight) : 0)
        let height = baseHeight + contentInsetsHeight + coveringTimeHeight
        
        let width = max(s.minimalContainerWidth, contentWidth)
        return CGSize(
            width: max(s.minimalContainerWidth, contentWidth),
            height: height
        )
    }
    
    private var containerSize: CGSize {
        return _containerSize.value(input: self)
    }
    
    private var statusSize: CGSize {
        return statusLabel.size(for: maximumBlockWidth)
    }
    
    private var deliverySize: CGSize {
        return CGSize(width: 15, height: 14)
    }
    
    private var timeSize: CGSize {
        let size = timeLabel.size(for: maximumBlockWidth)
        
        if renderMode == .contentBehindTime {
            return CGSize(width: size.width + size.height * 0.5, height: size.height)
        }
        else {
            return size
        }
    }
    
    private var footerSize: CGSize {
        let commonGap = iconSize.width + iconGap
        let originWidth = bounds.width - commonGap * 2
        return footer.size(for: originWidth)
    }
    
    private var minimalContainerWidth: CGFloat {
        if let _ = timeLabel.text {
            return deliverySize.width + gap + timeSize.width + timeInsets.horizontal
        }
        else {
            return 0
        }
    }
    
    private func calculateHorizontalBounds() -> (origin: CGFloat, width: CGFloat) {
        let leftX: CGFloat
        switch item?.position {
        case .left?: leftX = iconSize.width + iconGap
        case .right?: leftX = bounds.width - containerSize.width
        case .none: leftX = 0
        }
        
        return (origin: leftX, width: containerSize.width)
    }
}

fileprivate func getBackground(filledWith color: UIColor) -> UIImage? {
    let cornerRadius: CGFloat = 8
    let size = CGSize(width: cornerRadius * 2 + 1, height: cornerRadius * 2 + 1)
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    defer { UIGraphicsEndImageContext() }
    
    context?.setFillColor(color.cgColor)
    
    let fillRect = CGRect(origin: .zero, size: size)
    let fillPath = UIBezierPath(roundedRect: fillRect, cornerRadius: cornerRadius)
    context?.addPath(fillPath.cgPath)
    context?.fillPath()
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    let caps = UIEdgeInsets(top: cornerRadius + 1, left: cornerRadius + 1, bottom: cornerRadius + 1, right: cornerRadius + 1)
    return image?.resizableImage(withCapInsets: caps)
}

