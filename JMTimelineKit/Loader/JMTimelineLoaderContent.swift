//
//  JMTimelineLoaderContent.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

final public class JMTimelineLoaderContent: JMTimelineCanvas {
    private let waitingIndicator = UIActivityIndicatorView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        waitingIndicator.startAnimating()
        addSubview(waitingIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func apply(style: JMTimelineStyle) {
//        super.apply(style: style)
//
//        let style = style.convert(to: JMTimelineLoaderStyle.self)
//
//        waitingIndicator.style = style.waitingIndicatorStyle
//    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 50)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        waitingIndicator.frame = bounds
    }
}

