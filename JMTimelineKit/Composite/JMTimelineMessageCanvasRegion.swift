//
//  JMTimelineMessageCanvasRegion.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 09.12.2021.
//

import Foundation
import UIKit
import MapKit
import JMOnetimeCalculator

public struct JMTimelineMessageMeta {
    let timepoint: String
    let delivery: JMTimelineItemDelivery
    let status: String
    
    public init(
        timepoint: String,
        delivery: JMTimelineItemDelivery,
        status: String
    ) {
        self.timepoint = timepoint
        self.delivery = delivery
        self.status = status
    }
}

public class JMTimelineMessageCanvasRegion: UIView {
    public let quoteControl = UIView()
    public let decorationView = UIImageView()
    public let timeLabel = UILabel()
    public let deliveryView = JMTimelineDeliveryView()
    public let statusLabel = UILabel()

    private let renderMode: JMTimelineCompositeRenderMode
    private(set) var currentInfo: Any?
    private var renderOptions = JMTimelineMessageRegionRenderOptions()
    private var currentBlocks = [UIView & JMTimelineBlock]()
    private(set) var triggerHander: ((JMTimelineTrigger) -> Void)?
    
    public init(renderMode: JMTimelineCompositeRenderMode) {
        self.renderMode = renderMode
        
        super.init()
        
        addSubview(quoteControl)
        
        decorationView.layer.masksToBounds = true
        decorationView.isUserInteractionEnabled = true
        addSubview(decorationView)
        
        addSubview(statusLabel)
        
        timeLabel.layer.masksToBounds = true
        addSubview(timeLabel)
        
        deliveryView.contentMode = .right
        addSubview(deliveryView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup(info: Any, meta: JMTimelineMessageMeta?, options: JMTimelineMessageRegionRenderOptions) {
        currentInfo = info
        renderOptions = options
        
        if let meta = meta {
            timeLabel.text = meta.timepoint
            timeLabel.isHidden = false
            
            deliveryView.configure(delivery: meta.delivery)
            deliveryView.isHidden = false
            
            statusLabel.text = meta.status
            statusLabel.isHidden = false
        }
        else {
            timeLabel.isHidden = true
            deliveryView.isHidden = true
            statusLabel.isHidden = true
        }
    }
    
    func subscribeTo(triggerHander: @escaping (JMTimelineTrigger) -> Void) {
        self.triggerHander = triggerHander
    }
    
    public func integrateBlocks(_ blocks: [UIView & JMTimelineBlock], gap: CGFloat) {
        currentBlocks.forEach { $0.removeFromSuperview() }
        currentBlocks = blocks
        currentBlocks.forEach { decorationView.addSubview($0) }
        
        childrenGap = gap
    }
    
    var childrenGap = CGFloat(0)
    
    var isEmpty: Bool {
        return currentBlocks.isEmpty
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//
//        decorationView.backgroundColor = nil
//        decorationView.image = style.backgroundColor.flatMap(getBackground)
//        decorationView.layer.borderColor = style.borderColor?.cgColor
//        decorationView.layer.borderWidth = style.borderWidth ?? 0
//
//        statusLabel.textColor = style.statusColor
//        statusLabel.font = style.statusFont
//
//        deliveryView.tintColor = style.deliveryViewTintColor
//
//        if renderMode == .contentBehindTime {
//            timeLabel.backgroundColor = style.timeOverlayBackgroundColor
//            timeLabel.textColor = style.timeOverlayForegroundColor
//            timeLabel.font = style.timeFont
//            timeLabel.textAlignment = .center
//        }
//        else {
//            timeLabel.backgroundColor = UIColor.clear
//            timeLabel.textColor = style.timeRegularForegroundColor
//            timeLabel.font = style.timeFont
//            timeLabel.textAlignment = .right
//        }
//
//        footer.apply(style: style.reactionStyle)
//    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        quoteControl.frame = layout.quoteControlFrame
        quoteControl.layer.cornerRadius = layout.quoteControlRadius
        decorationView.frame = layout.decorationViewFrame
        decorationView.layer.cornerRadius = layout.backgroundViewCornerRadius
        statusLabel.frame = layout.statusLabelFrame
        timeLabel.frame = layout.timeLabelFrame
        timeLabel.layer.cornerRadius = layout.timeLabelCornerRadius
        deliveryView.frame = layout.deliveryViewFrame
        zip(currentBlocks, layout.childrenFrames).forEach { $0.0.frame = $0.1 }
    }
    
//    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if let style = style?.convert(to: JMTimelineCompositeStyle.self) {
//            decorationView.image = style.backgroundColor.flatMap(getBackground)
//        }
//    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            timeLabel: timeLabel,
            deliveryView: deliveryView,
            statusLabel: statusLabel,
            blocks: currentBlocks,
            blocksGap: childrenGap,
            renderMode: renderMode,
            renderOptions: renderOptions
        )
    }
    
    func handleLongPressInteraction(gesture: UILongPressGestureRecognizer) -> JMTimelineContentInteractionResult {
        for block in currentBlocks {
            guard block.bounds.contains(gesture.location(in: block)) else { continue }
            guard block.handleLongPressGesture(recognizer: gesture) else { continue }
            return .handled
        }
        
        if decorationView.bounds.contains(gesture.location(in: deliveryView)) {
            triggerHander?(.prepareForMenu)
            return .handled
        }

        return .handled
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let timeLabel: UILabel
    let deliveryView: UIView
    let statusLabel: UILabel
    let blocks: [UIView]
    let blocksGap: CGFloat
    let renderMode: JMTimelineCompositeRenderMode
    let renderOptions: JMTimelineMessageRegionRenderOptions
    
    private let sameGroupingGapCoef = CGFloat(0.2)
    private let maximumWidthPercentage = CGFloat(0.93)
    private let gap = CGFloat(5)
    private let timeOuterGap = CGFloat(6)
    
    var quoteControlFrame: CGRect {
        if renderOptions.isQuote {
            return CGRect(x: 0, y: 0, width: 4, height: bounds.height)
        }
        else {
            return .zero
        }
    }
    
    var quoteControlRadius: CGFloat {
        if renderOptions.isQuote {
            let frame = quoteControlFrame
            return min(frame.width, frame.height) * 0.5
        }
        else {
            return .zero
        }
    }
    
    var decorationViewFrame: CGRect {
        let size = containerSize
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    
    var backgroundViewCornerRadius: CGFloat {
        switch renderMode {
        case .bubble: return 8
        case .content(time: .near): return 0
        case .content(time: .over): return 8
        }
    }
    
    var statusLabelFrame: CGRect {
        let size = statusSize
        let topY = timeLabelFrame.midY - size.height * 0.5
        return CGRect(x: contentInsets.left, y: topY, width: size.width, height: size.height)
    }
    
    var timeLabelFrame: CGRect {
        let size = timeSize
        
        let leftX: CGFloat
        switch (renderMode, renderOptions.alignment) {
        case (.content(time: .near), .left):
            leftX = timeInsets.left
        case (.content(time: .near), .right):
            leftX = bounds.width - timeInsets.right - size.width
        case (.content(time: .over), _), (.bubble, _):
            leftX = bounds.width - timeInsets.right - size.width
        }
        
        let topY = decorationViewFrame.maxY - timeInsets.bottom - size.height
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
            y: contentInsets.top - blocksGap,
            width: 0,
            height: 0)
        
        return childrenSizes.map { size in
            rect = rect.offsetBy(dx: 0, dy: rect.height + blocksGap)
            rect.size = size
            return rect
        }
    }
    
    var totalSize: CGSize {
        let timeHeight: CGFloat
        if let _ = timeLabel.text {
            timeHeight = timeSize.height + timeInsets.vertical
        }
        else {
            timeHeight = contentInsets.top - contentInsets.bottom
        }
        
        let contentInsetsHeight: CGFloat
        let coveringMetaHeight: CGFloat
        switch renderMode {
        case .bubble(.compact), .bubble(time: .inline):
            contentInsetsHeight = contentInsets.vertical
            coveringMetaHeight = max(statusSize.height, timeHeight)
        case .content(time: .over):
            contentInsetsHeight = 0
            coveringMetaHeight = 0
        default:
            contentInsetsHeight = 0
            coveringMetaHeight = max(statusSize.height, timeHeight)
        }
        
        let height = childrenSize.height + contentInsetsHeight + coveringMetaHeight
        return CGSize(width: bounds.width, height: height)
    }
    
    private var contentInsets: UIEdgeInsets {
        switch renderMode {
        case .bubble(time: .standalone):
            return UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        case .bubble(time: .compact):
            return UIEdgeInsets(top: 14, left: 14, bottom: 0, right: 14)
        case .bubble(time: .inline):
            return UIEdgeInsets(top: 14, left: 14, bottom: 0, right: 14)
        case .content(time: .over):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .content(time: .near):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private var timeInsets: UIEdgeInsets {
        switch renderMode {
        case .bubble(time: .standalone):
            return UIEdgeInsets(top: 6, left: 6, bottom: 8, right: 8)
        case .bubble(time: .compact):
            return UIEdgeInsets(top: 6, left: 6, bottom: 8, right: 8)
        case .bubble(time: .inline):
            return UIEdgeInsets(top: 0, left: 6, bottom: 8, right: 8)
        case .content(time: .over):
            return UIEdgeInsets(top: 0, left: 2, bottom: 2, right: 2)
        case .content(time: .near):
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    private let _childrenSizes = JMLazyEvaluator<Layout, [CGSize]> { s in
        let widths: [CGFloat] = s.blocks.map { child in
            return child.size(for: s.bounds.width).width
        }
        
        let minimalWidth: CGFloat?
        if s.renderOptions.entireCanvas {
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
        
        return s.blocks.map { child in
            let height = child.size(for: maximumWidth).height
            return CGSize(width: maximumWidth, height: height)
        }
    }
    
    private var childrenSizes: [CGSize] {
        return _childrenSizes.value(input: self)
    }
    
    private var childrenSize: CGSize {
        let sizes = childrenSizes
        let gaps = blocksGap * CGFloat(sizes.count - 1)
        let maximumWidth = sizes.map({ $0.width }).max() ?? 0
        let totalHeight = sizes.map({ $0.height }).reduce(0, +) + gaps
        return CGSize(width: maximumWidth, height: totalHeight)
    }
    
    private let _containerSize = JMLazyEvaluator<Layout, CGSize> { s in
        let timeHeight: CGFloat
        if s.renderOptions.entireCanvas {
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
        
        let contentInsetsHeight: CGFloat
        let coveringTimeHeight: CGFloat
        switch s.renderMode {
        case .bubble:
            contentInsetsHeight = s.contentInsets.vertical
            coveringTimeHeight = max(s.statusSize.height, timeHeight)
        case .content(time: .over):
            contentInsetsHeight = 0
            coveringTimeHeight = 0
        default:
            contentInsetsHeight = 0
            coveringTimeHeight = max(s.statusSize.height, timeHeight)
        }
        
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
        return statusLabel.size(for: bounds.width)
    }
    
    private var deliverySize: CGSize {
        return CGSize(width: 15, height: 14)
    }
    
    private var timeSize: CGSize {
        let size = timeLabel.size(for: bounds.width)
        
        switch renderMode {
        case .content(time: .over):
            return CGSize(width: size.width + size.height * 0.5, height: size.height)
        default:
            return size
        }
    }
    
    private var minimalContainerWidth: CGFloat {
        if let _ = timeLabel.text {
            return deliverySize.width + gap + timeSize.width + timeInsets.horizontal
        }
        else {
            return 0
        }
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

