//
//  JMTimelineDataSource.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 16/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import SwiftyNSException
import JFCollectionViewManager
import DTModelStorage

final class JMTimelineDataSource: NSObject, UICollectionViewDelegateFlowLayout {
    var lastItemAppearHandler: (() -> Void)?
    var firstItemVisibleHandler: ((Bool) -> Void)?
    var mediaTapHandler: ((URL) -> Void)?
    var exceptionHandler: (() -> Void)?

    private let manager: DTCollectionViewManager
    private let history: JMTimelineHistory
    private let cache: JMTimelineCache
    private let factory: JMTimelineFactory
    private let provider: JMTimelineProvider
    private let interactor: JMTimelineInteractor
    
    weak var collectionView: UICollectionView?
    
    init(manager: DTCollectionViewManager,
         history: JMTimelineHistory,
         cache: JMTimelineCache,
         cellFactory: JMTimelineFactory,
         provider: JMTimelineProvider,
         interactor: JMTimelineInteractor) {
        self.manager = manager
        self.history = history
        self.cache = cache
        self.factory = cellFactory
        self.provider = provider
        self.interactor = interactor
        
        super.init()
    }
    
    func register(in collectionView: UICollectionView) {
        collectionView.backgroundColor = UIColor.clear
        collectionView.keyboardDismissMode = .interactive
        collectionView.transform = .invertedVertically
        collectionView.reloadData()
        self.collectionView = collectionView
    
        let updater = JMTimelineViewUpdater(collectionView: collectionView)
        manager.collectionViewUpdater = updater
        
        factory.register(manager: manager)
        attachProviders()
        
        updater.exceptionHandler = { [weak self] in
            self?.exceptionHandler?()
        }
    }
    
    func unregister(from collectionView: UICollectionView) {
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    private func attachProviders() {
        let _headerSizeProvider: (JMTimelineDateItem, IndexPath) -> CGSize = { [weak self] item, indexPath in
            guard let `self` = self else { return .zero }
            
            if item.logicOptions.contains(.enableSizeCaching), let size = self.cache.size(for: item.UUID) {
                return size
            }
            else {
                let view = self.factory.generateContent(for: item)
                let container = JMTimelineContainer(content: view)
                container.configure(item: item)

                let width = self.collectionView?.bounds.width ?? 0
                let height = container.size(for: width).height
                
                let size = CGSize(width: width, height: height)
                
                if item.logicOptions.contains(.enableSizeCaching) {
                    self.cache.cache(messageSize: size, for: item.UUID)
                }
                
                return size
            }
        }
        
        let _cellSizeProvider: (JMTimelineItem, IndexPath) -> CGSize = { [weak self] item, indexPath in
            guard let `self` = self else { return .zero }
            
            if item.logicOptions.contains(.enableSizeCaching), let size = self.cache.size(for: item.UUID) {
                return size
            }
            else {
                let view = self.factory.generateContent(for: item)
                let container = JMTimelineContainer(content: view)
                container.configure(item: item)
                
                let width = self.collectionView?.bounds.width ?? 0
                let height = container.size(for: width).height
                let size = CGSize(width: width, height: height)
                
                if item.logicOptions.contains(.enableSizeCaching) {
                    self.cache.cache(messageSize: size, for: item.UUID)
                }
                
                return size
            }
        }
    
        let _willDisplayCallback: (JMTimelineEventCell, JMTimelineItem, IndexPath) -> Void = { [weak self] cell, _, indexPath in
            guard let `self` = self else { return }
            
            cell.container.setNeedsLayout()
            
            if let latestIndexPath = self.history.latestIndexPath {
                if let visibleIndexPaths = self.collectionView?.indexPathsForVisibleItems {
                    self.firstItemVisibleHandler?(visibleIndexPaths.contains(latestIndexPath))
                }
                else {
                    self.firstItemVisibleHandler?(false)
                }
            }
            else {
                self.firstItemVisibleHandler?(false)
            }
            
            if indexPath == self.history.earliestIndexPath {
                self.lastItemAppearHandler?()
            }
        }
    
        let _didSelectCallback: (JMTimelineEventCell, JMTimelineItem, IndexPath) -> Void = { [weak self] _, item, _ in
            guard let `self` = self else { return }
            
            if let interactiveID = item.interactiveID {
                self.interactor.systemMessageTap(messageID: interactiveID)
            }
        }
        
        manager.referenceSizeForFooterView(withItem: JMTimelineDateItem.self, _headerSizeProvider)
        manager.sizeForCell(withItem: JMTimelineLoaderItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineSystemItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineTimepointItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelinePlainItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineBotItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineOrderItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineEmojiItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelinePhotoItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineMediaItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineAudioItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineEmailItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineLocationItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelinePlayableCallItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineRecordlessCallItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineRichItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineTaskItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineJoinableConferenceItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineFinishedConferenceItem.self, _cellSizeProvider)
        manager.sizeForCell(withItem: JMTimelineUniItem.self, _cellSizeProvider)

        manager.willDisplay(JMTimelineLoaderCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineSystemCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineTimepointCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelinePlainCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineBotCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineOrderCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineEmojiCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelinePhotoCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineMediaCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineAudioCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineEmailCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineLocationCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelinePlayableCallCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineRecordlessCallCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineRichCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineTaskCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineJoinableConferenceCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineFinishedConferenceCell.self, _willDisplayCallback)
        manager.willDisplay(JMTimelineUniCell.self, _willDisplayCallback)

        manager.didSelect(JMTimelineSystemCell.self, _didSelectCallback)
    }
}
