//
//  JMTimelineCompositeCallRecordlessBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineCompositeCallRecordlessStyle: JMTimelineStyle {
    let phoneTextColor: UIColor
    let phoneFont: UIFont
    let phoneLinesLimit: Int
}

final class JMTimelineCompositeCallRecordlessBlock: UIView, JMTimelineBlock {
    private let phoneLabel = UILabel()
    private weak var interactor: JMTimelineInteractor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        phoneLabel.lineBreakMode = .byTruncatingTail
        addSubview(phoneLabel)
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handlePhoneTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        self.interactor = interactor
    }
    
    func configure(phone: String) {
        phoneLabel.text = phone
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeCallRecordlessStyle.self)
        
        phoneLabel.textColor = style.phoneTextColor
        phoneLabel.font = style.phoneFont
        phoneLabel.numberOfLines = style.phoneLinesLimit
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
        phoneLabel.frame = layout.phoneLabelFrame
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            phoneLabel: phoneLabel
        )
    }
    
    @objc private func handlePhoneTap() {
        guard let phone = phoneLabel.text else { return }
        interactor.call(phone: phone)
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let phoneLabel: UILabel
    
    var phoneLabelFrame: CGRect {
        let height = phoneLabel.size(for: bounds.width).height
        return CGRect(x: 5, y: 0, width: bounds.width, height: height)
    }
    
    var totalSize: CGSize {
        return CGSize(width: bounds.width, height: phoneLabelFrame.height + 5)
    }
}
