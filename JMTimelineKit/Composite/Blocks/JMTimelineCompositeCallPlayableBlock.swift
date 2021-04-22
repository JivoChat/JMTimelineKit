//
//  JMTimelineCompositeCallPlayableBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineCompositeCallPlayableStyle: JMTimelineStyle {
    let controlBorderColor: UIColor
    let controlTintColor: UIColor
    let controlSide: CGFloat
    let controlCategory: UIFont.TextStyle
    let sliderThumbSide: CGFloat
    let sliderThumbColor: UIColor
    let sliderMinColor: UIColor
    let sliderMaxColor: UIColor
    let phoneTextColor: UIColor
    let phoneFont: UIFont
    let phoneLinesLimit: Int
    let durationTextColor: UIColor
    let durationFont: UIFont
}

final class JMTimelineCompositeCallPlayableBlock: UIView, JMTimelineBlock {
    private let backView = UIView()
    private let playButton = UIButton()
    private let pauseButton = UIButton()
    private let sliderControl = PlaybackSlider()
    private let phoneLabel = UILabel()
    private let durationLabel = UILabel()
    
    private var item: URL?
    private var duration: TimeInterval?
    private var style: JMTimelineCompositeCallPlayableStyle?
    private weak var provider: JMTimelineProvider!
    private weak var interactor: JMTimelineInteractor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backView.layer.borderWidth = 1
        addSubview(backView)
        
        let resumeIcon = UIImage(named: "player_resume", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        playButton.setImage(resumeIcon, for: .normal)
        playButton.setImage(resumeIcon, for: .highlighted)
        playButton.contentVerticalAlignment = .fill
        playButton.contentHorizontalAlignment = .center
        playButton.addTarget(self, action: #selector(handlePlayButton), for: .touchUpInside)
        addSubview(playButton)
        
        let pauseIcon = UIImage(named: "player_pause", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        pauseButton.setImage(pauseIcon, for: .normal)
        pauseButton.setImage(pauseIcon, for: .highlighted)
        pauseButton.contentVerticalAlignment = .fill
        pauseButton.contentHorizontalAlignment = .center
        pauseButton.addTarget(self, action: #selector(handlePauseButton), for: .touchUpInside)
        addSubview(pauseButton)
        
        sliderControl.minimumValue = 0
        sliderControl.maximumValue = 1.0
        addSubview(sliderControl)
        
        phoneLabel.lineBreakMode = .byTruncatingTail
        phoneLabel.adjustsFontSizeToFitWidth = true
        addSubview(phoneLabel)
        
        durationLabel.textAlignment = .right
        addSubview(durationLabel)
        
        adjustForCurrentStatus()
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handlePhoneTap))
        )
        
        sliderControl.beginHandler = { [weak self] progress in
            guard let `self` = self else { return false }
            guard let item = self.item else { return false }
            
            self.interactor.registerTouchingView(view: self.sliderControl)
            
            switch self.interactor.mediaPlayingStatus(item: item) {
            case .playing, .paused:
                self.interactor.pauseMedia(item: item)
                self.interactor.seekMedia(item: item, position: progress)
                return true
                
            case .none, .loading, .failed:
                return false
            }
            
        }
        
        sliderControl.adjustHandler = { [weak self] progress in
            guard let `self` = self else { return false }
            guard let item = self.item else { return false }
            
            switch self.interactor.mediaPlayingStatus(item: item) {
            case .playing, .paused:
                self.interactor.seekMedia(item: item, position: progress)
                return true
                
            case .none, .loading, .failed:
                return false
            }
        }
        
        sliderControl.endHandler = { [weak self] in
            guard let `self` = self else { return }
            guard let item = self.item else { return }
            
            self.interactor.unregisterTouchingView(view: self.sliderControl)
            self.interactor.resumeMedia(item: item)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unsubscribe()
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        self.provider = provider
        self.interactor = interactor
    }
    
    func configure(phone: String, item: URL, duration: TimeInterval?) {
        self.item = item
        self.duration = duration
        
        phoneLabel.text = phone
        adjustForCurrentStatus()
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeCallPlayableStyle.self)
        self.style = style
        
        let sliderImage = generateThumbImage(
            size: CGSize(width: style.sliderThumbSide, height: style.sliderThumbSide),
            category: style.controlCategory,
            color: style.sliderThumbColor
        )
        
        backView.layer.borderColor = style.controlBorderColor.cgColor
        playButton.tintColor = style.controlTintColor
        pauseButton.tintColor = style.controlTintColor
        sliderControl.minimumTrackTintColor = style.sliderMinColor
        sliderControl.maximumTrackTintColor = style.sliderMaxColor
        sliderControl.setThumbImage(sliderImage, for: .normal)
        phoneLabel.textColor = style.phoneTextColor
        phoneLabel.font = style.phoneFont
        phoneLabel.numberOfLines = style.phoneLinesLimit
        durationLabel.textColor = style.durationTextColor
        durationLabel.font = style.durationFont
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let _ = item {
            let layout = getLayout(size: size)
            return layout.totalSize
        }
        else {
            return CGSize(width: size.width, height: 0)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        backView.frame = layout.backFrame
        backView.layer.cornerRadius = layout.backCornerRadius
        playButton.frame = layout.buttonFrame
        playButton.layer.cornerRadius = layout.buttonCornerRadius
        pauseButton.frame = layout.buttonFrame
        pauseButton.layer.cornerRadius = layout.buttonCornerRadius
        sliderControl.frame = layout.sliderControlFrame
        phoneLabel.frame = layout.phoneLabelFrame
        durationLabel.frame = layout.durationLabelFrame
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let _ = window {
            subscribe()
        }
        else {
            unsubscribe()
        }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            phoneLabel: phoneLabel,
            durationLabel: durationLabel,
            style: style
        )
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaPlayerState),
            name: Notification.Name.JMMediaPlayerState,
            object: nil
        )
    }
    
    private func unsubscribe() {
        NotificationCenter.default.removeObserver(self)
        
        if let item = item {
            interactor?.stopMedia(item: item)
        }
    }
    
    private func adjustForCurrentStatus() {
        isHidden = (item == nil)
        guard let item = item else { return }
        
        let status = interactor.mediaPlayingStatus(item: item)
        switch status {
        case .none:
            playButton.isHidden = false
            pauseButton.isHidden = true
            sliderControl.value = 0
            durationLabel.text = duration.flatMap { generateProgressCaption(current: 0, duration: $0) }

        case .loading:
            playButton.isHidden = true
            pauseButton.isHidden = false
            sliderControl.value = 0
            durationLabel.text = nil
            
        case .failed:
            playButton.isHidden = false
            pauseButton.isHidden = true
            sliderControl.value = 0
            durationLabel.text = nil
            
        case .playing(let current, let duration):
            playButton.isHidden = true
            pauseButton.isHidden = false
            sliderControl.value = Float(current / duration)
            durationLabel.text = generateProgressCaption(current: current, duration: duration)
            
        case .paused(let current, let duration):
            playButton.isHidden = false
            pauseButton.isHidden = true
            sliderControl.value = Float(current / duration)
            durationLabel.text = generateProgressCaption(current: current, duration: duration)
        }

        setNeedsLayout()
    }
    
    private func generateProgressCaption(current: TimeInterval, duration: TimeInterval) -> String {
        let currentCaption = provider.formattedTimeForPlayback(current)
        let durationCaption = provider.formattedTimeForPlayback(duration)
        return "\(currentCaption) / \(durationCaption)"
    }
    
    @objc private func handlePlayButton() {
        if let item = item {
            interactor.playMedia(item: item)
        }
        
        adjustForCurrentStatus()
    }
    
    @objc private func handlePauseButton() {
        if let item = item {
            interactor.pauseMedia(item: item)
        }
        
        adjustForCurrentStatus()
    }
    
    @objc private func handlePhoneTap() {
        guard let phone = phoneLabel.text else { return }
        interactor.call(phone: phone)
    }
    
    @objc private func handleMediaPlayerState(_ notification: Notification) {
        adjustForCurrentStatus()
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let phoneLabel: UILabel
    let durationLabel: UILabel
    let style: JMTimelineCompositeCallPlayableStyle?
    
    var backFrame: CGRect {
        return CGRect(x: 5, y: 0, width: buttonSize.width, height: buttonSize.height)
    }
    
    var backCornerRadius: CGFloat {
        return backFrame.width * 0.5
    }
    
    var buttonFrame: CGRect {
        return backFrame.insetBy(dx: 7, dy: 7)
    }
    
    var buttonCornerRadius: CGFloat {
        return buttonFrame.width * 0.5
    }
    
    var sliderControlFrame: CGRect {
        let leftX = backFrame.maxX + 12
        let width = bounds.width - leftX
        let height = CGFloat(15)
        let topY = backFrame.midY - height * 0.5
        return CGRect(x: leftX, y: topY, width: width, height: height)
    }
    
    var phoneLabelFrame: CGRect {
        let leftX = sliderControlFrame.minX + 1
        let size = phoneLabel.sizeThatFits(.zero)
        let topY = backFrame.maxY - size.height * 0.5
        let width = min(durationLabelFrame.minX - leftX - 5, size.width)
        return CGRect(x: leftX, y: topY, width: width, height: size.height)
    }
    
    var durationLabelFrame: CGRect {
        let size = durationLabel.sizeThatFits(.zero)
        let topY = backFrame.maxY - size.height * 0.5
        
        if durationLabel.hasText {
            let leftX = bounds.width - size.width
            return CGRect(x: leftX, y: topY, width: size.width, height: size.height)
        }
        else {
            return CGRect(x: bounds.width, y: topY, width: 0, height: 0)
        }
    }
    
    var totalSize: CGSize {
        let height = max(buttonSize.height, phoneLabelFrame.maxY, durationLabelFrame.maxY) + 5
        return CGSize(width: bounds.width, height: height)
    }
    
    private var buttonSize: CGSize {
        let side = style?.controlSide ?? 40
        let category = style?.controlCategory ?? .body
        return CGSize(width: side, height: side).scaled(category: category)
    }
}

fileprivate final class PlaybackSlider: JMTimelineObservableSlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return super.trackRect(forBounds: bounds).insetBy(dx: 0, dy: -0.5)
    }
}

fileprivate func generateThumbImage(size: CGSize, category: UIFont.TextStyle, color: UIColor) -> UIImage? {
    let basicCanvasSize = CGSize(width: 15, height: 15)
    let scaledCanvasSize = basicCanvasSize.scaled(category: category)
    let scaledCanvasBounds = CGRect(origin: .zero, size: scaledCanvasSize)
    let thumbInsets = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    let thumbFrame = scaledCanvasBounds.reduceBy(insets: thumbInsets)

    let thumbLayer = CALayer()
    thumbLayer.frame = thumbFrame
    thumbLayer.backgroundColor = color.cgColor
    thumbLayer.cornerRadius = thumbFrame.width * 0.5
    thumbLayer.allowsEdgeAntialiasing = true

    let parentLayer = CALayer()
    parentLayer.frame = scaledCanvasBounds
    parentLayer.allowsEdgeAntialiasing = true
    parentLayer.addSublayer(thumbLayer)

    UIGraphicsBeginImageContextWithOptions(scaledCanvasSize, false, 0)
    defer { UIGraphicsEndImageContext() }
    
    if let context = UIGraphicsGetCurrentContext() {
        parentLayer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    else {
        return nil
    }
}
