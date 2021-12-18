//
//  JMTimelineSingleCanvas.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 16.12.2021.
//

import Foundation
import UIKit

public class JMTimelineSingleCanvas<Region: UIView>: JMTimelineCanvas {
    public let region: Region

    public init(region: Region) {
        self.region = region
        
        super.init(frame: .zero)
        
        addSubview(region)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return region.sizeThatFits(size)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        region.frame = bounds
    }
}
