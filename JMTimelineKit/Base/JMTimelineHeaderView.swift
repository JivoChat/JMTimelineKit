//
//  JMTimelineHeaderView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTModelStorage

class JMTimelineHeaderView: UICollectionReusableView {
    private(set) lazy var container: JMTimelineContainer = { obtainContainer() }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func obtainContent() -> JMTimelineCanvas {
        abort()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return container.sizeThatFits(size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = bounds
    }
    
    fileprivate func obtainContainer() -> JMTimelineContainer {
        return JMTimelineContainer(content: obtainContent())
    }
}
