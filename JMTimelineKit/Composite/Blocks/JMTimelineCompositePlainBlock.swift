//
//  JMTimelineCompositePlainBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import TypedTextAttributes
import JMMarkdownKit

public struct JMTimelineCompositePlainStyle: JMTimelineStyle {
    let textColor: UIColor
    let identityColor: UIColor?
    let linkColor: UIColor
    let font: UIFont
    let boldFont: UIFont?
    let italicsFont: UIFont?
    let strikeFont: UIFont?
    let lineHeight: CGFloat
    let alignment: NSTextAlignment
    let underlineStyle: NSUnderlineStyle?
    let parseMarkdown: Bool

    public init(textColor: UIColor,
                identityColor: UIColor?,
                linkColor: UIColor,
                font: UIFont,
                boldFont: UIFont?,
                italicsFont: UIFont?,
                strikeFont: UIFont?,
                lineHeight: CGFloat,
                alignment: NSTextAlignment,
                underlineStyle: NSUnderlineStyle?,
                parseMarkdown: Bool) {
        self.textColor = textColor
        self.identityColor = identityColor
        self.linkColor = linkColor
        self.font = font
        self.boldFont = boldFont
        self.italicsFont = italicsFont
        self.strikeFont = strikeFont
        self.lineHeight = lineHeight
        self.alignment = alignment
        self.underlineStyle = underlineStyle
        self.parseMarkdown = parseMarkdown
    }
}

final class JMTimelineCompositePlainBlock: JMMarkdownLabel, JMTimelineBlock {
    private var mentionProvider: JMMarkdownMentionProvider?
    
    init() {
        super.init(provider: nil)
        
        backgroundColor = UIColor.clear
        numberOfLines = 0
        isInteractive = true
        enableLongPress = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        mentionProvider = provider.mentionProvider
        
        urlHandler = { url, interaction in
            interactor.follow(url: url, interaction: interaction)
        }
    }
    
    func configure(content: String) {
        setContents(.caption(content))
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositePlainStyle.self)
        let mentionProvider = self.mentionProvider
        
        textAlignment = style.alignment
        
        updateParser { purpose in
            let parser = JMMarkdownParser(
                font: style.font,
                color: style.textColor,
                additionalAttributes: TextAttributes()
                    .minimumLineHeight(style.lineHeight)
                    .maximumLineHeight(style.lineHeight),
                types: [.autoLink, .email, .phone, .mention] +
                    (style.parseMarkdown ? [.mdItalics, .mdBold, .mdStrike, .mdLink] : [])
            )
            
            parser.autoLinkElement.color = style.linkColor ?? style.textColor
            parser.autoLinkElement.font = style.font
            parser.autoLinkElement.underlineStyle = style.underlineStyle
            parser.autoLinkElement.linksEnabled = (purpose == .interact)
            
            parser.emailElement.color = style.identityColor ?? style.textColor
            parser.emailElement.font = style.font
            parser.emailElement.underlineStyle = style.underlineStyle
            parser.emailElement.linksEnabled = (purpose == .interact)
            
            parser.phoneElement.color = style.identityColor ?? style.textColor
            parser.phoneElement.font = style.font
            parser.phoneElement.underlineStyle = style.underlineStyle
            parser.phoneElement.linksEnabled = (purpose == .interact)
            
            parser.mentionElement.mentionProvider = mentionProvider
            parser.mentionElement.color = style.linkColor
            parser.mentionElement.font = style.font
            parser.mentionElement.underlineStyle = nil
            parser.mentionElement.linksEnabled = (purpose == .interact)
            
            if style.parseMarkdown {
                parser.mdBoldElement.font = style.boldFont ?? style.font
                parser.mdBoldElement.color = parser.fontColor
                
                parser.mdItalicsElement.font = style.italicsFont ?? style.font
                parser.mdItalicsElement.color = parser.fontColor
            
                parser.mdStrikeElement.font = style.strikeFont ?? style.font
                parser.mdStrikeElement.color = parser.fontColor
                
                parser.mdLinkElement.color = style.identityColor ?? style.textColor
                parser.mdLinkElement.font = style.font
                parser.mdLinkElement.underlineStyle = style.underlineStyle
                parser.mdLinkElement.linksEnabled = (purpose == .interact)
            }
            
            return parser
        }
        
        render()
    }
    
    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        guard let _ = retrieveURL(gesture: recognizer) else { return false }
        handleLongPress(recognizer)
        return true
    }
}
