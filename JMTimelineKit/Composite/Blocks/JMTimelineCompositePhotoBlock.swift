//
//  JMTimelineCompositeEventPhotoBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import Lottie

extension Notification.Name {
    static let messagePhotoTap = Notification.Name("messagePhotoTap")
}

struct JMTimelineCompositePhotoStyle: JMTimelineStyle {
    let ratio: CGFloat
    let contentMode: UIView.ContentMode
    let errorStubBackgroundColor: UIColor
    let errorStubDescriptionColor: UIColor
}

fileprivate protocol Renderer: class {
    init()
    func pause()
    func resume()
    func reset()
}

final class JMTimelineCompositePhotoBlock: UIView, JMTimelineBlock {
    private let waitingIndicator = UIActivityIndicatorView()
    private var ratio = CGFloat(1.0)
    
    private var renderer: (UIView & Renderer)?
    private var url: URL?
    private var originalSize: CGSize?
    private var cropped = false
    private var allowFullscreen = true
    private var style: JMTimelineCompositePhotoStyle!
    
    private weak var provider: JMTimelineProvider!
    private weak var interactor: JMTimelineInteractor!

    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        waitingIndicator.hidesWhenStopped = true
        addSubview(waitingIndicator)
        
        if #available(iOS 11.0, *) {
            accessibilityIgnoresInvertColors = true
        }
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var waitingIndicatorStyle: UIActivityIndicatorView.Style {
        get { return waitingIndicator.style }
        set { waitingIndicator.style = newValue }
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        self.provider = provider
        self.interactor = interactor
    }
    
    func configure(url: URL, originalSize: CGSize, cropped: Bool, allowFullscreen: Bool) {
        self.url = url
        self.originalSize = originalSize
        self.cropped = cropped
        self.allowFullscreen = allowFullscreen
        
        waitingIndicator.startAnimating()
        
        let canvasWidth = originalSize.width * UIScreen.main.scale
        provider.retrieveResource(from: url, canvasWidth: canvasWidth) { [weak self] resource in
            guard let `self` = self, url == self.url else {
                return
            }
            
            guard let resource = resource else {
                self.waitingIndicator.startAnimating()
                self.renderer?.reset(); return
            }
            
            switch resource {
            case .raw(let data) where NSData.sd_imageFormat(forImageData: data) == .undefined:
                self.ensureRenderer(NativeRenderer.self).configure(data: data)
            case .raw(let data):
                self.ensureRenderer(UniversalRenderer.self).configure(data: data)
            case .lottie(let animation):
                self.ensureRenderer(LottieRenderer.self).configure(animation: animation)
            case let .failure(errorDescription):
                let style = ErrorRenderer.Style(backgroundColor: self.style.errorStubBackgroundColor, errorDescriptionColor: self.style.errorStubDescriptionColor)
                let image = UIImage(named: "unavailable_image_stub", in: Bundle.framework, compatibleWith: nil)
                self.ensureRenderer(ErrorRenderer.self).configure(image: image, errorDescription: errorDescription, style: style)
            }
            
            self.waitingIndicator.stopAnimating()
        }
    }
    
    func reset() {
        url = nil
        originalSize = nil
        renderer?.reset()
        waitingIndicator.stopAnimating()
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositePhotoStyle.self)
        self.style = style
        
        ratio = style.ratio
        contentMode = style.contentMode
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let originalSize = originalSize else { return .zero }
        
        let scale = UIScreen.main.scale
        
        if cropped {
            return originalSize
        }
        else if originalSize.width == 0 || originalSize.height == 0 {
            let height = size.width * ratio
            return CGSize(width: size.width, height: height)
        }
        else if (originalSize.width / scale) > size.width {
            let normalizedWidth = originalSize.width / scale
            let normalizedHeight = originalSize.height / scale
            let coef = size.width / normalizedWidth
            let width = normalizedWidth * coef
            let height = normalizedHeight * coef
            return CGSize(width: width, height: height)
        }
        else {
            let width = originalSize.width / scale
            let height = originalSize.height / scale
            return CGSize(width: width, height: height)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        waitingIndicator.frame = bounds
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if let _ = newWindow {
            renderer?.resume()
        }
        else {
            renderer?.pause()
        }
    }
    
    private func ensureRenderer<T: UIView & Renderer>(_ type: T.Type) -> T {
        if let element = renderer as? T {
            return element
        }
        
        let newElement = T.init()
        
        renderer?.removeFromSuperview()
        renderer = newElement
        renderer.flatMap(addSubview)
        
        renderer?.frame = bounds
        renderer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return newElement
    }
    
    @objc private func handleTap() {
        guard let url = url, allowFullscreen else { return }
        
        switch url.pathExtension {
        case "jpg", "jpeg", String(): interactor.requestMedia(url: url, mime: "image/jpeg", completion: { _ in })
        case "png": interactor.requestMedia(url: url, mime: "image/png", completion: { _ in })
        default: interactor.requestMedia(url: url, mime: nil, completion: { _ in })
        }
    }
}

fileprivate final class UniversalRenderer: UIImageView, Renderer {
    init() {
        super.init(frame: .zero)
        
        contentMode = .scaleAspectFill
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(url: URL, completion: @escaping (URL?) -> Void) {
        sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [],
            progress: nil,
            completed: { _, _, _, imageURL in completion(imageURL) })
    }
    
    func configure(data: Data) {
        image = UIImage(data: data)
    }
    
    func pause() {
    }
    
    func resume() {
    }
    
    func reset() {
        image = nil
    }
}

fileprivate final class NativeRenderer: UIImageView, Renderer {
    init() {
        super.init(frame: .zero)
        
        contentMode = .scaleAspectFill
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(data: Data) {
        image = UIImage(data: data)
    }
    
    func configure(image: UIImage) {
        self.image = image
    }
    
    func pause() {
    }
    
    func resume() {
    }
    
    func reset() {
        image = nil
    }
}

fileprivate final class LottieRenderer: UIView, Renderer {
    private let core = AnimationView()
    
    init() {
        super.init(frame: .zero)
        
        core.frame = bounds
//        core.loopMode = .loop
        core.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(core)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(animation: Animation) {
        core.animation = animation
//        core.play()
    }
    
    func pause() {
//        core.pause()
    }
    
    func resume() {
//        core.play()
    }
    
    func reset() {
//        core.stop()
        core.animation = nil
    }
}

fileprivate final class ErrorRenderer: UIView, Renderer {
    private lazy var contentView = UIView()
    private lazy var mainContainer = UIView()
    private lazy var imageView = UIImageView()
    private lazy var errorDescriptionLabel = UILabel()
    
    func configure(image: UIImage?, errorDescription: String?, style: Style) {
        imageView.image = image
        errorDescriptionLabel.text = errorDescription
        
        backgroundColor = style.backgroundColor
        errorDescriptionLabel.textColor = style.errorDescriptionColor
        
        setUpSubviews()
    }
    
    func pause() {
    }
    
    func resume() {
    }

    func reset() {
    }
    
    override func layoutSubviews() {
        let layout = Layout(superView: self, contentView: contentView, imageView: imageView, errorDescriptionLabel: errorDescriptionLabel)
        
        contentView.frame = layout.contentViewFrame
        mainContainer.frame = layout.mainContainerFrame
        imageView.frame = layout.imageViewFrame
        errorDescriptionLabel.frame = layout.errorDescriptionFrame
    }
    
    private func setUpSubviews() {
        errorDescriptionLabel.numberOfLines = 0
        
        contentView.backgroundColor = .clear
        mainContainer.backgroundColor = .clear
        
        mainContainer.addSubview(imageView)
        mainContainer.addSubview(errorDescriptionLabel)
        contentView.addSubview(mainContainer)
        addSubview(contentView)
    }
}

extension ErrorRenderer {
    struct Style {
        let backgroundColor: UIColor
        let errorDescriptionColor: UIColor
    }
    
    struct Layout {
        let superView: UIView
        let contentView: UIView
        let imageView: UIView
        let errorDescriptionLabel: UIView
        
        var imageViewToErrorDescriptionLabelMargin: CGFloat {
            return 15
        }
        
        var errorDescriptionHMargin: CGFloat {
            return 15
        }
        
        var contentViewFrame: CGRect {
            return superView.bounds
        }
        
        var mainContainerFrame: CGRect {
            let mainContainerWidth = max(imageViewFrame.size.width, errorDescriptionFrame.size.width)
            let mainContainerHeight = imageViewFrame.size.height + imageViewToErrorDescriptionLabelMargin + errorDescriptionFrame.size.height
            let mainContainerSize = CGSize(width: mainContainerWidth, height: mainContainerHeight)
            
            let mainContaineFrameOriginX = contentView.center.x - mainContainerWidth / 2
            let mainContaineFrameOriginY = contentView.center.y - mainContainerHeight / 2
            let mainContainerFrameOrigin = CGPoint(x: mainContaineFrameOriginX, y: mainContaineFrameOriginY)
            
            return CGRect(origin: mainContainerFrameOrigin, size: mainContainerSize)
        }
        
        var imageViewFrame: CGRect {
            let imageViewSize = imageView.intrinsicContentSize
            let imageViewFrameOrigin = CGPoint(x: errorDescriptionSize.width / 2 - imageViewSize.width / 2, y: .zero)
            return CGRect(origin: imageViewFrameOrigin, size: imageViewSize)
        }
        
        var errorDescriptionSize: CGSize {
            let errorDescriptionWidth = contentViewFrame.size.width - errorDescriptionHMargin * 2
            return errorDescriptionLabel.size(for: errorDescriptionWidth)
        }
        
        var errorDescriptionFrame: CGRect {
            let imageViewFrameOriginTranslationY = imageViewFrame.height + imageViewToErrorDescriptionLabelMargin
            let errorDescriptionFrameOrigin = CGPoint(x: .zero, y: imageViewFrameOriginTranslationY)
            
            return CGRect(origin: errorDescriptionFrameOrigin, size: errorDescriptionSize)
        }
    }
}
