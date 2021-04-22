//
//  JMTimelineBlock.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 04.06.2020.
//  Copyright © 2020 JivoSite. All rights reserved.
//

import Foundation
import UIKit

public protocol JMTimelineBlock: JMTimelineStylable, JMTimelineLinkable {
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool
}
