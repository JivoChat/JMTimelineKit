//
//  JMTimelineInteractor.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 30/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import JMMarkdownKit

public enum ChatTimelineTap {
    
    case regular
    case long
}

public enum JMTimelineMediaStatus {
    case available
    case accessDenied
    case unknownError
}

public protocol JMTimelineInteractor: AnyObject {
    var timelineView: UIView? { get set }
    
    var requestMediaHandler: ((URL, String?) -> Void)? { get set }
    var tapHandler: ((JMTimelineItem, ChatTimelineTap) -> Void)? { get set }
    
    func registerTouchingView(view: UIView)
    func unregisterTouchingView(view: UIView)
    func hasTouchingView() -> Bool
    
    func senderIconTap(item: JMTimelineItem)
    func senderIconLongPress(item: JMTimelineItem)
    func systemMessageTap(messageID: String?)
    func systemButtonTap(buttonID: String)
    
    func playMedia(item: URL)
    func pauseMedia(item: URL)
    func resumeMedia(item: URL)
    func seekMedia(item: URL, position: Float)
    func stopMedia(item: URL)
    func mediaPlayingStatus(item: URL) -> JMTimelineMediaPlayerItemStatus
    
    func follow(url: URL, interaction: JMMarkdownURLInteraction)
    func call(phone: String)
    func addPerson(name: String, phone: String)
    func callForOrder(phone: String)
    func toggleMessageReaction(uuid: String, emoji: String)
    func presentMessageReactions(uuid: String)
    func performMessageSubaction(uuid: String, actionID: String)
    func joinConference(url: URL)

    func requestMedia(url: URL, mime: String?, completion: @escaping (JMTimelineMediaStatus) -> Void)
    func requestAudio(url: URL, mime: String?)
    func requestLocation(coordinate: CLLocationCoordinate2D)
    
    func constructMenuForMessage()
    func constructMenuForLink(url: URL)
    func prepareForItem(uuid: String)
    func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool
}

public extension JMTimelineInteractor {
    func requestMedia(url: URL, mime: String?, completion: @escaping (JMTimelineMediaStatus) -> Void = { _ in }) {
        self.requestMedia(url: url, mime: mime, completion: completion)
    }
}
