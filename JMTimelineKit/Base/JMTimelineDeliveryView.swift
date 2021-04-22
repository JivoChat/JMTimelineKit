//
//  JMTimelineDeliveryVieww.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 30/07/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit

extension Bundle {
    static var framework: Bundle {
        return Bundle(for: JMTimelineView.self)
    }
}

final class JMTimelineDeliveryView: UIImageView {
    func configure(delivery: JMTimelineItemDelivery) {
        switch delivery {
        case .hidden: image = nil
        case .sent: image = UIImage(named: "message_sent", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        case .delivered: image = UIImage(named: "message_sent", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        case .seen: image = UIImage(named: "message_seen", in: Bundle.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        case .failed: image = UIImage(named: "message_failed", in: Bundle.framework, compatibleWith: nil)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size)
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    
    var totalSize: CGSize {
        let size = CGSize(width: 12, height: 12)
        return size.scaled(category: .caption2)
    }
}
