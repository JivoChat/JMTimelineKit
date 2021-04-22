//
// Created by Stan Potemkin on 09/08/2018.
// Copyright (c) 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public struct JMTimelineLoaderStyle: JMTimelineStyle {
    let waitingIndicatorStyle: UIActivityIndicatorView.Style
    
    public init(waitingIndicatorStyle: UIActivityIndicatorView.Style) {
        self.waitingIndicatorStyle = waitingIndicatorStyle
    }
}

public struct JMTimelineLoaderObject: JMTimelineObject {
    public init() {
    }
}

public final class JMTimelineLoaderItem: JMTimelineItem {
}
