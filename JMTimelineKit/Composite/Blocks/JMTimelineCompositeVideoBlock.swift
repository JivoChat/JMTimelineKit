//
//  JMTimelineCompositeVideoBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMImageLoader

struct JMTimelineCompositeVideoStyle {
    let backgroundColor: UIColor
    let dimmingColor: UIColor
    let playBackgroundColor: UIColor
    let playIcon: UIImage
    let playTintColor: UIColor
    let ratio: CGFloat
}

final class JMTimelineCompositeVideoBlock: UIImageView, JMTimelineBlock {
    private var url: URL?
    private var ratio = CGFloat(1.0)
    
    private let dimView = UIView()
    private let playIcon = UIImageView()
    
    private var interactor: JMTimelineInteractor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
        isUserInteractionEnabled = true
        
        dimView.isUserInteractionEnabled = false
        addSubview(dimView)
        
        playIcon.contentMode = .center
        dimView.addSubview(playIcon)
        
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
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
    }
    
    func configure(url: URL) {
        self.url = url
        
        jmLoadImage(with: url)
//        af_setImage(
//            withURLRequest: URLRequest(url: url),
//            placeholderImage: nil,
//            imageTransition: .crossDissolve(0.25)
//        )
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeVideoStyle.self)
        
        backgroundColor = style.backgroundColor
        dimView.backgroundColor = style.dimmingColor
        playIcon.backgroundColor = style.playBackgroundColor
        playIcon.image = style.playIcon
        playIcon.tintColor = style.playTintColor
        ratio = style.ratio
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        dimView.frame = layout.dimViewFrame
        playIcon.frame = layout.playIconFrame
        playIcon.layer.cornerRadius = layout.playIconCornerRadius
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: size.width * ratio)
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size)
        )
    }
    
    @objc private func handleTap() {
        guard let url = url else { return }
        interactor.requestMedia(url: url, mime: nil)
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    
    var dimViewFrame: CGRect {
        return bounds
    }
    
    var playIconFrame: CGRect {
        let size = CGSize(width: 40, height: 40)
        
        return CGRect(
            x: bounds.minX + (bounds.width - size.width) * 0.5,
            y: bounds.minY + (bounds.height - size.height) * 0.5,
            width: size.width,
            height: size.height
        )
    }
    
    var playIconCornerRadius: CGFloat {
        return playIconFrame.width * 0.5
    }
}
