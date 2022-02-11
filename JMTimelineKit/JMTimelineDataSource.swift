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

public struct JMTimelineDataSourceProviders {
    public let headerSizeProvider: (JMTimelineItem, IndexPath) -> CGSize
    public let cellSizeProvider: (JMTimelineItem, IndexPath) -> CGSize
    public let willDisplayHandler: (JMTimelineEventCell, JMTimelineItem, IndexPath) -> Void
    public let didSelectHandler: (JMTimelineEventCell, JMTimelineItem, IndexPath) -> Void
}

public enum JMTimelineEvent {
    case earliestPointOfHistory
    case latestPointOfHistory(hasData: Bool)
    case mediaTap(url: URL)
    case exceptionHappened
}

final class JMTimelineDataSource: NSObject, UICollectionViewDelegateFlowLayout {
    private let manager: DTCollectionViewManager
    private let history: JMTimelineHistory
    private let cache: JMTimelineCache
    private let factory: JMTimelineFactory
    private let eventHandler: (JMTimelineEvent) -> Void

    private(set) var providers: JMTimelineDataSourceProviders
    weak var collectionView: UICollectionView?

    init(manager: DTCollectionViewManager,
         history: JMTimelineHistory,
         cache: JMTimelineCache,
         cellFactory: JMTimelineFactory,
         eventHandler: @escaping (JMTimelineEvent) -> Void) {
        self.manager = manager
        self.history = history
        self.cache = cache
        self.factory = cellFactory
        self.eventHandler = eventHandler
        
        providers = JMTimelineDataSourceProviders(
            headerSizeProvider: { item, indexPath in
                return .zero
            },
            cellSizeProvider: { item, indexPath in
                return .zero
            },
            willDisplayHandler: { cell, item, indexPath in
            },
            didSelectHandler: { cell, item, indexPath in
            }
        )
        
        super.init()
        
        providers = JMTimelineDataSourceProviders(
            headerSizeProvider: { [weak self] item, indexPath in
                return self?.provideHeaderSize(item: item, indexPath: indexPath) ?? .zero
            },
            cellSizeProvider: { [weak self] item, indexPath in
                return self?.provideCellSize(item: item, indexPath: indexPath) ?? .zero
            },
            willDisplayHandler: { [weak self] cell, item, indexPath in
                self?.handleWillDisplay(cell: cell, item: item, indexPath: indexPath)
            },
            didSelectHandler: { [weak self] cell, item, indexPath in
                self?.handleDidSelect(cell: cell, item: item, indexPath: indexPath)
            }
        )
    }
    
    func register(in collectionView: UICollectionView) {
        collectionView.backgroundColor = UIColor.clear
        collectionView.keyboardDismissMode = .interactive
        collectionView.transform = .invertedVertically
        collectionView.reloadData()
        self.collectionView = collectionView
    
        let updater = JMTimelineViewUpdater(collectionView: collectionView)
        manager.collectionViewUpdater = updater
        
        factory.register(manager: manager, providers: providers)
        
        updater.exceptionHandler = { [weak self] in
            self?.eventHandler(.exceptionHappened)
        }
    }
    
    func unregister(from collectionView: UICollectionView) {
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    private func provideHeaderSize(item: JMTimelineItem, indexPath: IndexPath) -> CGSize {
        if item.logicOptions.contains(.enableSizeCaching), let size = cache.size(for: item.uid) {
            return size
        }
        else {
            let canvas = factory.generateCanvas(for: item)
            let container = JMTimelineContainer(canvas: canvas)
            container.configure(item: item)

            let width = collectionView?.bounds.width ?? 0
            let height = container.size(for: width).height
            let size = CGSize(width: width, height: height)
            
            if item.logicOptions.contains(.enableSizeCaching) {
                cache.cache(messageSize: size, for: item.uid)
            }
            
            return size
        }
    }

    private func provideCellSize(item: JMTimelineItem, indexPath: IndexPath) -> CGSize {
        if item.logicOptions.contains(.enableSizeCaching), let size = cache.size(for: item.uid) {
            return size
        }
        else {
            let canvas = factory.generateCanvas(for: item)
            let container = JMTimelineContainer(canvas: canvas)
            container.configure(item: item)
            
            let width = collectionView?.bounds.width ?? 0
            let height = container.size(for: width).height
            let size = CGSize(width: width, height: height)
            
            if item.logicOptions.contains(.enableSizeCaching) {
                cache.cache(messageSize: size, for: item.uid)
            }
            
            return size
        }
    }
    
    private func handleWillDisplay(cell: JMTimelineEventCell, item: JMTimelineItem, indexPath: IndexPath) -> Void {
        cell.container.setNeedsLayout()
        
        if let latestIndexPath = history.latestIndexPath {
            if let visibleIndexPaths = collectionView?.indexPathsForVisibleItems {
                let hasData = visibleIndexPaths.contains(latestIndexPath)
                eventHandler(.latestPointOfHistory(hasData: hasData))
            }
            else {
                eventHandler(.latestPointOfHistory(hasData: false))
            }
        }
        else {
            eventHandler(.latestPointOfHistory(hasData: false))
        }
        
        if indexPath == history.earliestIndexPath {
            eventHandler(.earliestPointOfHistory)
        }
    }
    
    private func handleDidSelect(cell: JMTimelineEventCell, item: JMTimelineItem, indexPath: IndexPath) -> Void {
//        if let interactiveID = item.interactiveID {
//            interactor.systemMessageTap(messageID: interactiveID)
//        }
    }
}
