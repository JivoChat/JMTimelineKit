//
//  JMTimelineMessageLocationItem.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import CoreLocation

public struct JMTimelineMessageLocationInfo: JMTimelineInfo {
    let coordinate: CLLocationCoordinate2D
    
    public init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

public typealias JMTimelineLocationStyle = JMTimelineCompositeLocationBlockStyle

public final class JMTimelineMessageLocationItem: JMTimelineMessageItem {
}
