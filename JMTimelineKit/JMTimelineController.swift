//
//  JMTimelineController.swift
//  JMTimeline
//
//  Created by Stan Potemkin on 01/10/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import DTCollectionViewManager

public final class JMTimelineController: NSObject, DTCollectionViewManageable, UIScrollViewDelegate {
    public var optionalCollectionView: UICollectionView?
    public var lastItemAppearHandler: (() -> Void)?
    
    public let cache: JMTimelineCache
    public let history: JMTimelineHistory
    
    public let factory: JMTimelineFactory
    private var dataSource: JMTimelineDataSource?
    
    public init(factory: JMTimelineFactory, cache: JMTimelineCache) {
        self.cache = cache
        self.history = JMTimelineHistory(factory: factory, cache: cache)
        self.factory = factory
    }
    
    public func attach(timelineView: JMTimelineView,
                       provider: JMTimelineProvider,
                       interactor: JMTimelineInteractor,
                       firstItemVisibleHandler: @escaping (Bool) -> Void,
                       exceptionHandler: @escaping () -> Void) {
        optionalCollectionView = timelineView
        
        let oldStorage = manager.storage
        manager = DTCollectionViewManager()
        manager.storage = oldStorage
        manager.memoryStorage.defersDatasourceUpdates = true
        
        history.configure(manager: manager)
        history.prepare()
        
        dataSource = JMTimelineDataSource(
            manager: manager,
            history: history,
            cache: cache,
            cellFactory: factory,
            provider: provider,
            interactor: interactor
        )
        
        dataSource?.register(in: timelineView)
        
        dataSource?.lastItemAppearHandler = lastItemAppearHandler
        dataSource?.firstItemVisibleHandler = firstItemVisibleHandler
        dataSource?.exceptionHandler = exceptionHandler
    }
    
    public func detach(timelineView: JMTimelineView) {
        dataSource?.unregister(from: timelineView)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        (scrollView as? JMTimelineView)?.dismissOwnMenu()
    }
}
