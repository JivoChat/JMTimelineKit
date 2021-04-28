//
//  ChatCompositeCellContentView.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 20/10/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit

protocol ChatCompositeCellBlock {
    var extraBottomInset: CGFloat { get }
}

final class ChatCompositeCellContentView: UIView {
    private(set) var children = [UIView & ChatCompositeCellBlock]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isEmpty: Bool {
        return children.isEmpty
    }
    
    func configure(children: [UIView & ChatCompositeCellBlock]) {
        self.children.forEach { $0.removeFromSuperview() }
        self.children = children
        self.children.forEach { addSubview($0) }
    }
    
    func adjustStyle(for item: ChatItem) {
        children.forEach { child in
            if let block = child as? ChatCompositeCellPlainBlock {
                switch item.sender {
                case .client:
                    let color = DesignBook.shared.color(.white)
                    let font = obtainPlainFont()
                    block.stylize(textColor: color, font: font)
                    
                case .agent:
                    let color = DesignBook.shared.color(.black)
                    let font = obtainPlainFont()
                    block.stylize(textColor: color, font: font)
                    
                case .system:
                    let color = DesignBook.shared.color(.steel)
                    let font = obtainSystemFont()
                    block.stylize(textColor: color, font: font)
                }
            }
            else if let _ = child as? ChatCompositeCellAttributedBlock {
                return
            }
            else if let block = child as? ChatCompositeCellEmailBlock {
                switch item.sender {
                case .client:
                    block.textColor = DesignBook.shared.color(.white).withAlpha(0.9)
                    block.font = obtainEmailFont()
                    
                case .agent, .system:
                    assertionFailure()
                }
            }
            else if let block = child as? ChatCompositeCellPhotoBlock {
                switch item.sender {
                case .client:
                    block.waitingIndicatorStyle = .white
                    
                case .agent:
                    block.waitingIndicatorStyle = .gray
                    
                case .system:
                    assertionFailure()
                }
            }
            else if let block = child as? ChatCompositeCellVideoBlock {
                switch item.sender {
                case .client:
                    block.tintColor = DesignBook.shared.color(.greenJivo)
                    
                case .agent:
                    block.tintColor = DesignBook.shared.color(.grayRegular)
                    
                case .system:
                    assertionFailure()
                }
            }
            else if let block = child as? ChatCompositeCellMediaBlock {
                switch item.sender {
                case .client:
                    block.textColor = DesignBook.shared.color(.white)
                    block.tintColor = DesignBook.shared.color(.greenJivo)
                    
                case .agent:
                    block.textColor = DesignBook.shared.color(.black)
                    block.tintColor = DesignBook.shared.color(.grayRegular)
                    
                case .system:
                    assertionFailure()
                }
            }
//            else {
//                assertionFailure()
//            }
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getLayout(size: size)
        return layout.totalSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = getLayout(size: bounds.size)
        zip(children, layout.childrenFrames).forEach { $0.0.frame = $0.1 }
    }
    
    private func getLayout(size: CGSize) -> Layout {
        return Layout(
            bounds: CGRect(origin: .zero, size: size),
            children: children
        )
    }
}

fileprivate struct Layout {
    let bounds: CGRect
    let children: [UIView & ChatCompositeCellBlock]
    
    var childrenFrames: [CGRect] {
        var rect = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
        var maxWidth = CGFloat(0)
        
        let frames: [CGRect] = children.map { child in
            let childContainingSize = CGSize(width: bounds.width, height: .infinity)
            let childSize = child.sizeThatFits(childContainingSize)
            
            maxWidth = max(maxWidth, childSize.width)
            
            rect = rect.offsetBy(dx: 0, dy: rect.height)
            rect.size.height = childSize.height
            return rect
        }
        
        return frames.map { frame in
            return CGRect(
                x: frame.minX,
                y: frame.minY,
                width: maxWidth,
                height: frame.height
            )
        }
    }
    
    var totalSize: CGSize {
        let maxBlockWidth = childrenFrames.map({ $0.width }).max() ?? 0
        let bottomInset = children.last?.extraBottomInset ?? 0
        
        let width = min(bounds.width, maxBlockWidth)
        let height = (childrenFrames.last?.maxY ?? 0) - bottomInset
        return CGSize(width: width, height: height)
    }
}

fileprivate func obtainPlainFont() -> UIFont {
    return DesignBook.shared.font(
        weight: .regular,
        category: .callout,
        defaultSizes: DesignBookFontSize(compact: 16, regular: 16),
        maximumSizes: nil
    )
}

fileprivate func obtainEmailFont() -> UIFont {
    return DesignBook.shared.font(
        weight: .bold,
        category: .footnote,
        defaultSizes: DesignBookFontSize(compact: 13, regular: 13),
        maximumSizes: nil
    )
}

fileprivate func obtainCallHeaderFont() -> UIFont {
    return DesignBook.shared.font(
        weight: .regular,
        category: .callout,
        defaultSizes: DesignBookFontSize(compact: 16, regular: 16),
        maximumSizes: nil
    )
}

fileprivate func obtainPlayFont() -> UIFont {
    return DesignBook.shared.font(
        weight: .regular,
        category: .subheadline,
        defaultSizes: DesignBookFontSize(compact: 14, regular: 14),
        maximumSizes: nil
    )
}

fileprivate func obtainSystemFont() -> UIFont {
    return DesignBook.shared.font(
        weight: .regular,
        category: .footnote,
        defaultSizes: DesignBookFontSize(compact: 14, regular: 14),
        maximumSizes: nil
    )
}
