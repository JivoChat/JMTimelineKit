//
//  JMTimelineMessagePhotoItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import UIKit

public struct JMTimelineMessagePhotoInfo: JMTimelineInfo {
    public let url: URL
    public let width: Int
    public let height: Int
    public let allowFullscreen: Bool
    
    public init(url: URL,
                width: Int,
                height: Int,
                allowFullscreen: Bool) {
        self.url = url
        self.width = width
        self.height = height
        self.allowFullscreen = allowFullscreen
    }
}

public struct JMTimelinePhotoStyle: JMTimelineStyle {
    let waitingIndicatorStyle: UIActivityIndicatorView.Style
    let errorStubStyle: ErrorStubStyle
    let ratio: CGFloat
    let contentMode: UIView.ContentMode
    
    public init(waitingIndicatorStyle: UIActivityIndicatorView.Style,
                errorStubStyle: ErrorStubStyle,
                ratio: CGFloat,
                contentMode: UIView.ContentMode) {
        self.waitingIndicatorStyle = waitingIndicatorStyle
        self.errorStubStyle = errorStubStyle
        self.ratio = ratio
        self.contentMode = contentMode
    }
}

public extension JMTimelinePhotoStyle {
    struct ErrorStubStyle {
        let backgroundColor: UIColor
        let errorDescriptionColor: UIColor
        
        public init(backgroundColor: UIColor,
                    errorDescriptionColor: UIColor) {
            self.backgroundColor = backgroundColor
            self.errorDescriptionColor = errorDescriptionColor
        }
    }
}

public final class JMTimelineMessagePhotoItem: JMTimelineMessageItem {
}

extension JMTimelineMessagePhotoInfo {
    func scaleMeta(minimum: CGFloat = 0, maximum: CGFloat = 0) -> (size: CGSize, cropped: Bool) {
        let scaledWidth = CGFloat(width) / UIScreen.main.scale
        let scaledHeight = CGFloat(height) / UIScreen.main.scale
        let minimalSide = min(scaledWidth, scaledHeight)
        
        if minimalSide == 0 {
            return (.zero, false)
        }
        else if minimum > 0, minimalSide < minimum {
            let size = CGSize(width: minimum, height: minimum)
            return (size, true)
        }
        else if maximum > 0, minimalSide > maximum {
            let size = CGSize(width: maximum, height: maximum)
            return (size, true)
        }
        else {
            let size = CGSize(width: minimalSide, height: minimalSide)
            return (size, true)
        }
    }
}
