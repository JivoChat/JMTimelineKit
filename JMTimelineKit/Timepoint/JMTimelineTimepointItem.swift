//
//  JMTimelineTimepointItem.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 21.07.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JMRepicKit

public struct JMTimelineTimepointInfo: JMTimelineInfo {
    let caption: String
    
    public init(caption: String) {
        self.caption = caption
    }
}

public struct JMTimelineTimepointStyle: JMTimelineStyle {
    let margins: UIEdgeInsets
    let alignment: NSTextAlignment
    let font: UIFont
    let textColor: UIColor
    let padding: UIEdgeInsets
    let borderWidth: CGFloat
    let borderColor: UIColor
    let borderRadius: CGFloat?
    
    public init(margins: UIEdgeInsets,
                alignment: NSTextAlignment,
                font: UIFont,
                textColor: UIColor,
                padding: UIEdgeInsets,
                borderWidth: CGFloat,
                borderColor: UIColor,
                borderRadius: CGFloat?) {
        self.margins = margins
        self.alignment = alignment
        self.font = font
        self.textColor = textColor
        self.padding = padding
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.borderRadius = borderRadius
    }
}

public final class JMTimelineTimepointItem: JMTimelinePayloadItem<JMTimelineTimepointInfo> {
    override var groupingID: String? {
        return nil
    }
}
