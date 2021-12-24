//
//  JMTimelineSingleCanvas.swift
//  JMTimelineKit
//
//  Created by Stan Potemkin on 16.12.2021.
//

import Foundation
import UIKit

open class JMTimelineSingleCanvas<Provider, Interactor, Region: UIView>: JMTimelineLinkedCanvas<Provider, Interactor> {
    public let region: Region

    public init(provider: Provider, interactor: Interactor, region: Region) {
        self.region = region
        
        super.init(provider: provider, interactor: interactor)
        
        addSubview(region)
    }
    
    required public init?(coder aDecoder: NSCoder) {
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
