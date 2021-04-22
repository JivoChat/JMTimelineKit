//
//  JMTimelineLinkable.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation

public protocol JMTimelineLinkable: class {
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor)
}
