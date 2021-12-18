//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineRichStyle: JMTimelineStyle {
    public init() {
    }
}

public struct JMTimelineMessageRichInfo: JMTimelineInfo {
    let content: NSAttributedString
    
    public init(content: NSAttributedString) {
        self.content = content
    }
}

public final class JMTimelineMessageRichItem: JMTimelineMessageItem {
}
