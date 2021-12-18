//
//  JMTimelineMessageCanvas.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit
import JMOnetimeCalculator

extension JMTimelineTrigger {
    static let senderIconTap = JMTimelineTrigger()
    static let senderIconLongPress = JMTimelineTrigger()
    static let performMessageReaction = JMTimelineTrigger()
    static let listMessageReactions = JMTimelineTrigger()
    static let performMessageAction = JMTimelineTrigger()
}

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
    public let contentStyle: JMTimelineStyle
    
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

public enum JMTimelineCompositeRenderMode: Equatable {
    public enum BubbleTime { case standalone, compact, inline }
    case bubble(time: BubbleTime)
    
    public enum ContentTime { case near, over }
    case content(time: ContentTime)
}

public struct JMTimelineMessageRenderOptions {
    public let position: JMTimelineItemPosition
    
    public init(
        position: JMTimelineItemPosition = .left
    ) {
        self.position = position
    }
}

public struct JMTimelineMessageRegionRenderOptions {
    public let isQuote: Bool
    public let entireCanvas: Bool
    public let alignment: JMTimelineItemPosition

    public init(
        isQuote: Bool = false,
        entireCanvas: Bool = false,
        alignment: JMTimelineItemPosition = .left
    ) {
        self.isQuote = isQuote
        self.entireCanvas = entireCanvas
        self.alignment = alignment
    }
}

public class JMTimelineMessageCanvas: JMTimelineCanvas {
    public let senderIcon = JMRepicView.standard()
    public let senderCaption = JMTimelineCompositeSenderLabel()
    public let footer = JMTimelineContainerFooter()

    private var kindID = String()
    private var currentRegions = [JMTimelineMessageCanvasRegion]()

    public init() {
        super.init(frame: .zero)
        
        addSubview(senderIcon)
        
        addSubview(senderCaption)
        
        addSubview(footer)
        
        senderIcon.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleSenderIconTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(item: JMTimelineItem) {
        super.configure(item: item)
        
        let item = item.convert(to: JMTimelineMessageItem.self)
        
        if item.payload.kindID != kindID {
            if !currentRegions.isEmpty {
                let list = cachedRegions[kindID] ?? Array()
                cachedRegions[kindID] = list + [currentRegions]
            }
            
            kindID = item.payload.kindID
            
            currentRegions.forEach { $0.removeFromSuperview() }
            defer {
                currentRegions.forEach { addSubview($0) }
            }
            
            if var list = cachedRegions[kindID], !list.isEmpty {
                currentRegions = list.removeFirst()
                cachedRegions[kindID] = list
            }
            else {
                currentRegions = item.payload.contentGenerator()
            }
        }
        
        item.payload.contentPopulator(currentRegions)
        
        populateMeta(item: item)
        populateBlocks(item: item)
        
        if item.hasLayoutOptions(.groupLastElement) {
            senderIcon.configure(item: item.payload.sender.icon)
            senderIcon.isHidden = false
        }
        else {
            senderIcon.isHidden = true
        }
        
        footer.configure(
            reactions: item.extraActions.reactions,
            actions: item.extraActions.actions)
        
        footer.reactionHandler = { index in
            let reaction = item.extraActions.reactions[index]
            item.triggerHandler(.performMessageReaction(reaction.emoji))
        }
        
        footer.actionHandler = { index in
            let action = item.extraActions.actions[index]
            item.triggerHandler(.performMessageAction(action.ID))
        }
        
        footer.presentReactionsHandler = {
            item.triggerHandler(.listMessageReactions)
        }
    }
    
    func populateBlocks(item: JMTimelineItem) {
        assertionFailure()
    }
    
    open func configure(object: JMTimelineInfo, style: JMTimelineStyle, provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        assertionFailure()
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineCompositeStyle.self)
//
//        senderCaption.backgroundColor = style.senderBackground
//        senderCaption.textColor = style.senderColor
//        senderCaption.font = style.senderFont
//        senderCaption.padding = style.senderPadding
//        senderCaption.layer.cornerRadius = style.senderCorner
//        senderCaption.layer.masksToBounds = true
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
        senderIcon.frame = layout.senderIconFrame
        senderCaption.frame = layout.senderLabelFrame
        senderCaption.textAlignment = layout.senderLabelAlignment
        zip(currentRegions, layout.regionsFrames).forEach { $0.0.frame = $0.1 }
        footer.frame = layout.footerFrame
    }
    
    private func getLayout(size: CGSize) -> Layout {
        guard let item = item as? JMTimelineMessageItem else {
            preconditionFailure()
        }
        
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            sender: item.payload.sender,
            senderLabel: senderCaption,
            regions: currentRegions,
            regionsGap: 10,
            footer: footer,
            layoutOptions: item.layoutOptions,
            layoutValues: item.layoutValues,
            renderOptions: item.payload.renderOptions,
            contentInsets: item.layoutValues.margins
        )
    }
    
    private func populateMeta(item: JMTimelineItem) {
        let item = item.convert(to: JMTimelineMessageItem.self)
        
        if item.hasLayoutOptions(.groupFirstElement) {
            senderCaption.text = item.payload.sender.name
        }
        else {
            senderCaption.text = nil
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
                item.triggerHandler(.senderIconLongPress)
            }
            else {
                for region in currentRegions {
                    let point = gesture.location(in: region)
                    guard region.bounds.contains(point) else {
                        continue
                    }
                    
                    if region.handleLongPressInteraction(gesture: gesture) == .handled {
                        return .handled
                    }
                }
            }
        }
        
        return .handled
    }
    
    @objc func handleSenderIconTap() {
        guard let item = item else { return }
        item.triggerHandler(.senderIconTap)
    }
}

fileprivate var cachedRegions = [String: Array<[JMTimelineMessageCanvasRegion]>]()

fileprivate struct Layout {
    let bounds: CGRect
//    let item: JMTimelineMessageItem!
    let sender: JMTimelineItemSender
    let senderLabel: UILabel
    let regions: [UIView]
    let regionsGap: CGFloat
    let footer: JMTimelineContainerFooter
    let layoutOptions: JMTimelineLayoutOptions
    let layoutValues: JMTimelineItemLayoutValues
    let renderOptions: JMTimelineMessageRenderOptions
    let contentInsets: UIEdgeInsets

    private let sameGroupingGapCoef = CGFloat(0.2)
    private let iconSize = CGSize(width: 30, height: 30)
    private let iconGap = CGFloat(10)
    private let maximumWidthPercentage = CGFloat(0.93)
    private let gap = CGFloat(5)
    private let timeOuterGap = CGFloat(6)
    
    var senderIconFrame: CGRect {
        if !layoutOptions.contains(.groupLastElement) {
            return .zero
        }
        
        if sender.icon == nil {
            return .zero
        }
        
        let relativeFrame = regionsFrames.last ?? .zero
        let topY = relativeFrame.maxY - iconSize.height
        return CGRect(x: 0, y: topY, width: iconSize.width, height: iconSize.height)
    }
    
    private let _senderLabelFrame = JMLazyEvaluator<Layout, CGRect> { s in
        if !s.layoutOptions.contains(.groupFirstElement) {
            return .zero
        }
        
        if s.sender.name == nil {
            return .zero
        }
        
        let containerWidth = s.bounds.width - (s.senderIconFrame.maxX + s.iconGap) - s.contentInsets.right
        let size = s.senderLabel.size(for: containerWidth)
        
        switch s.renderOptions.position {
        case .left:
            let leftX = s.senderIconFrame.maxX + s.iconGap
            return CGRect(x: leftX, y: 0, width: size.width, height: size.height)
        case .right:
            let leftX = s.bounds.width - s.contentInsets.right
            return CGRect(x: leftX, y: 0, width: size.width, height: size.height)
        }
    }
    
    var senderLabelFrame: CGRect {
        return _senderLabelFrame.value(input: self)
    }
    
    var senderLabelAlignment: NSTextAlignment {
        switch renderOptions.position {
        case .left: return .left
        case .right: return .right
        }
    }
    
    var regionsFrames: [CGRect] {
        let allValues = regionsSizes
        let totalWidth = allValues.map(\.width).max() ?? 0
        
        var rect = CGRect(
            x: 0,
            y: contentInsets.top - regionsGap,
            width: 0,
            height: 0
        )
        
        return allValues.map { size in
            rect = rect.offsetBy(dx: 0, dy: rect.height + regionsGap)
            rect.size = size

            switch renderOptions.position {
            case .left:
                rect.origin.x = senderIconFrame.maxX + iconGap
            case .right:
                rect.origin.x = totalWidth - contentInsets.right - rect.width
            }
            
            return rect
        }
    }
    
    var footerFrame: CGRect {
        let commonGap = iconSize.width + iconGap
        let size = footerSize
        
        let topY = (regionsFrames.last ?? .zero).maxY + 5
        let width = size.width
        let height = size.height
        
        switch renderOptions.position {
        case .left:
            return CGRect(x: commonGap, y: topY, width: width, height: height)
        case .right:
            return CGRect(x: bounds.width - width, y: topY, width: width, height: height)
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
        
        let regionsHeight = regionsSizes.map(\.height).reduce(0, +)
        let regionsGaps = regionsGap * CGFloat(regionsSizes.count - 1)
        
        let footerHeight: CGFloat
        if footerSize.height > 0 {
            footerHeight = footerSize.height + 6
        }
        else {
            footerHeight = 0
        }
        
        let height = senderHeight + regionsHeight + regionsGaps + footerHeight
        return CGSize(width: bounds.width, height: height)
    }
    
    private var maximumRegionWidth: CGFloat {
        let iconSpace = iconSize.width + iconGap
        let readableWidth = (bounds.width - layoutValues.margins.horizontal) * maximumWidthPercentage
        return readableWidth - contentInsets.horizontal - iconSpace
    }
    
    private let _regionsSizes = JMLazyEvaluator<Layout, [CGSize]> { s in
        return s.regions.map { region in
            region.size(for: s.maximumRegionWidth)
        }
    }
    
    private var regionsSizes: [CGSize] {
        return _regionsSizes.value(input: self)
    }
    
    private var footerSize: CGSize {
        let commonGap = iconSize.width + iconGap
        let originWidth = bounds.width - commonGap * 2
        return footer.size(for: originWidth)
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

