//
//  JMTimelineHistory.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 16/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import DTCollectionViewManager
import DTModelStorage

fileprivate class JMTimelineHistoryContext {
    var shouldResetCache: Bool
    
    init(shouldResetCache: Bool) {
        self.shouldResetCache = shouldResetCache
    }
}

public final class JMTimelineHistory {
    private let factory: JMTimelineFactory
    public let cache: JMTimelineCache
    
    var manager: DTCollectionViewManager!
    
    private var grouping = JMTimelineGrouping()
    private var recentItemsMap = [Int: Any]()
    private var registeredHeaderModels = [Int: Date]()
    private var registeredFooterModels = [IndexPath: JMTimelineItem]()
    private var registeredItemIDs = Set<String>()
    private var isTyping = false
    
    public init(factory: JMTimelineFactory, cache: JMTimelineCache) {
        self.factory = factory
        self.cache = cache
    }

    public var hasDeferredChanges: Bool {
        // it replaces the default delegate while applying the deferred updates,
        // so we can rely on this replacement
        if manager.memoryStorage.delegate !== manager.collectionViewUpdater {
            return true
        }
        else if let update = manager.memoryStorage.currentUpdate {
            return !update.isEmpty
        }
        else {
            return false
        }
    }
    
    public var numberOfItems: Int {
        return manager.memoryStorage.totalNumberOfItems
    }
    
    var earliestIndexPath: IndexPath? {
        let earliestSectionIndex = grouping.historyLastIndex
        guard
            !manager.memoryStorage.sections.isEmpty,
            earliestSectionIndex < manager.memoryStorage.sections.endIndex
            else { return nil }
        
        let earliestSection = manager.memoryStorage.sections[earliestSectionIndex]
        if earliestSection.numberOfItems == 0 {
            return nil
        }
        else if let earliestItem = earliestSection.item(at: earliestSection.numberOfItems - 1) as? JMTimelineItem {
            return manager.memoryStorage.indexPath(forItem: earliestItem)
        }
        else {
            return nil
        }
    }
    
    var latestIndexPath: IndexPath? {
        let latestSectionIndex = grouping.historyFrontIndex
        guard
            !manager.memoryStorage.sections.isEmpty,
            latestSectionIndex < manager.memoryStorage.sections.endIndex
            else { return nil }
        
        let latestSection = manager.memoryStorage.sections[latestSectionIndex]
        if latestSection.numberOfItems == 0 {
            return nil
        }
        else if let latestItem = latestSection.item(at: 0) as? JMTimelineItem {
            return manager.memoryStorage.indexPath(forItem: latestItem)
        }
        else {
            return nil
        }
    }
    
    func configure(manager: DTCollectionViewManager) {
        self.manager = manager
        
        manager.memoryStorage.headerModelProvider = { [weak self] section in
            self?.registeredHeaderModels[section]
        }
        
        manager.memoryStorage.supplementaryModelProvider = { [weak self] _, indexPath in
            self?.registeredFooterModels[indexPath]
        }
        
        grouping.reset()
    }
    
    public func prepare() {
        manager.memoryStorage.updateWithoutAnimations {
            manager.memoryStorage.setItems([], forSection: grouping.bottomIndex)
            manager.memoryStorage.setItems([], forSection: grouping.typingIndex)
            manager.memoryStorage.setItems([], forSection: grouping.historyFrontIndex)
            manager.memoryStorage.setItems([], forSection: grouping.topIndex)
        }
    }
    
    public func setTopItem(_ item: JMTimelineItem?) -> Bool {
        let section = grouping.topIndex
        
        if let item = item {
            if let oldIndexPath = manager.memoryStorage.indexPath(forItem: item) {
                manager.memoryStorage.updateWithoutAnimations {
                    manager.memoryStorage.deleteSections([oldIndexPath.section])
                    manager.memoryStorage.setItems([item], forSection: section)
                }
            }
            else {
                manager.memoryStorage.setItems([item], forSection: section)
            }
            
            return true
        }
        else if manager.memoryStorage.numberOfItems(inSection: section) > 0 {
            manager.memoryStorage.setItems([], forSection: section)
            return true
        }
        else {
            manager.memoryStorage.setItems([], forSection: section)
            return false
        }
    }
    
    public func setBottomItem(_ item: JMTimelineItem?) -> Bool {
        let section = grouping.bottomIndex
    
        if let item = item {
            manager.memoryStorage.setItems([item], forSection: section)
            return true
        }
        else if manager.memoryStorage.numberOfItems(inSection: section) > 0 {
            manager.memoryStorage.setItems([], forSection: section)
            return true
        }
        else {
            manager.memoryStorage.setItems([], forSection: section)
            return false
        }
    }
    
    public func setTyping(item: JMTimelineItem?) {
        let section = grouping.typingIndex
        
        switch (item, isTyping) {
        case (nil, false):
            break
        case (nil, true):
            isTyping = false
            if let existingItem = manager.memoryStorage.items(inSection: section)?.first as? JMTimelineItem {
                try? manager.memoryStorage.removeItem(existingItem)
            }
        case (let payload, false):
            isTyping = true
            manager.memoryStorage.addItem(payload, toSection: section)
        case (let payload, true):
            manager.memoryStorage.setItems([payload], forSection: section)
        }
    }
    
    func item(at indexPath: IndexPath) -> JMTimelineItem? {
        return manager.memoryStorage.item(at: indexPath) as? JMTimelineItem
    }
    
    public func item(byUUID uuid: String) -> JMTimelineItem? {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem else { continue }
                guard uuid == item.UUID else { continue }
                return item
            }
        }
        
        return nil
    }
    
    public func fill(with items: [JMTimelineItem]) {
        registeredItemIDs.removeAll()
        registeredHeaderModels.removeAll()
        registeredFooterModels.removeAll()
        
        let historyIndices = grouping.historyIndices
        grouping.reset()
        
        manager.memoryStorage.updateWithoutAnimations {
            manager.memoryStorage.deleteSections(historyIndices)
        }
        
        manager.memoryStorage.updateWithoutAnimations {
            prepend(items: items, resetCache: true)
        }
    }
    
    public func append(items: [JMTimelineItem]) {
        manager.memoryStorage.defersDatasourceUpdates = false
        defer { manager.memoryStorage.defersDatasourceUpdates = true }

        manager.memoryStorage.performUpdates {
            items.forEach { item in
                let messageClearDate = item.date.withoutTime()
        
                if let groupIndex = grouping.grow(date: messageClearDate) {
                    let footerIndexPath = IndexPath(item: 0, section: groupIndex)
                    registeredHeaderModels[groupIndex] = messageClearDate
                    registeredFooterModels[footerIndexPath] = factory.generateDateItem(date: messageClearDate)
                    
                    let model = SectionModel()
                    model.setItems([item])
                    manager.memoryStorage.insertSection(model, atIndex: grouping.historyFrontIndex)
                }
                else {
                    insertAndAdjust(item: item)
                }
        
                registeredItemIDs.insert(item.UUID)
            }
        }
        manager.collectionViewUpdater?.storageNeedsReloading()
    }
    
    public func append(item: JMTimelineItem) {
        append(items: [item])
    }
    
    public func prepend(items: [JMTimelineItem], resetCache: Bool) {
        let context = JMTimelineHistoryContext(shouldResetCache: resetCache)
        manager.memoryStorage.performUpdates {
            items.forEach { item in
                if registeredItemIDs.contains(item.UUID) {
                    return
                }
                
                let messageClearDate = item.date.withoutTime()
                
                if let groupIndex = grouping.group(for: messageClearDate) {
                    prependAndAdjust(context: context, item: item, into: groupIndex)
                }
                else if let groupIndex = grouping.grow(date: messageClearDate) {
                    let footerIndexPath = IndexPath(item: 0, section: groupIndex)
                    registeredHeaderModels[groupIndex] = messageClearDate
                    registeredFooterModels[footerIndexPath] = factory.generateDateItem(date: messageClearDate)
                    
                    let model = SectionModel()
                    manager.memoryStorage.insertSection(model, atIndex: groupIndex)
                    prependAndAdjust(context: context, item: item, into: groupIndex)
                }
            }
        }
    }
    
    public func replaceItem(byUUID UUID: String, with replacingItem: JMTimelineItem) {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem else { return }
                guard UUID == item.UUID else { continue }

                replacingItem.removeRenderOptions(.allOptions)
                replacingItem.addRenderOptions(item.renderOptions)
                try? manager.memoryStorage.replaceItem(item, with: replacingItem)

                return
            }
        }
    }
    
    public func removeItem(byUUID UUID: String) {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem else { return }
                guard UUID == item.UUID else { continue }

                let nextIndex = index - 1
                if item.renderOptions.contains(.groupFirstElement), index > 0, let nextItem = section.item(at: nextIndex) as? JMTimelineItem, item.groupingID == nextItem.groupingID {
                    nextItem.removeRenderOptions(nextItem.renderOptions)
                    nextItem.addRenderOptions(item.renderOptions)
                    cache.resetSize(for: nextItem.UUID)
                    manager.memoryStorage.reloadItem(nextItem)
                }
                
                try? manager.memoryStorage.removeItem(item)
                
                return
            }
        }
    }
    
    private func prependAndAdjust(context: JMTimelineHistoryContext, item: JMTimelineItem, into groupIndex: Int) {
        if let newerItem = recentItemsMap[groupIndex] {
            adjustAfterPrepend(context: context, olderItem: item, newerItem: newerItem)
        }
        else {
            item.removeRenderOptions([.groupBottomMargin])
            
//            if let newerItem = context.recentItemsMap[groupIndex - 1] as? JMTimelineItem {
//                if belongToSameGroup(item, newerItem) {
//                    newerItem.removeRenderOptions([.groupTopMargin])
//                    cache.resetSize(for: newerItem.UUID)
//                    manager.memoryStorage.reloadItem(newerItem)
//                }
//            }
            
//            if groupIndex < manager.memoryStorage.sections.count {
//                let section = manager.memoryStorage.sections[groupIndex]
//                if section.numberOfItems > 0, let newerItem = section.item(at: section.numberOfItems - 1) as? JMTimelineItem, belongToSameGroup(item, newerItem) {
//                    newerItem.removeRenderOptions([.groupTopMargin])
//                    cache.resetSize(for: newerItem.UUID)
//                    manager.memoryStorage.reloadItem(newerItem)
//                }
//            }
        }
        
        manager.memoryStorage.addItem(item, toSection: groupIndex)
        recentItemsMap[groupIndex] = item
        
        registeredItemIDs.insert(item.UUID)
    }
    
    private func adjustAfterPrepend(context: JMTimelineHistoryContext, olderItem: Any, newerItem: Any) {
        guard let olderItem = olderItem as? JMTimelineItem else { return }
        guard let newerItem = newerItem as? JMTimelineItem else { return }
        
        if belongToSameGroup(olderItem, newerItem) {
            newerItem.removeRenderOptions([.groupTopMargin, .groupFirstElement])
            olderItem.removeRenderOptions([.groupLastElement, .groupBottomMargin])
            
            if context.shouldResetCache {
                cache.resetSize(for: newerItem.UUID)
                cache.resetSize(for: olderItem.UUID)
                context.shouldResetCache = false
            }
        }
    }
    
    private func belongToSameGroup(_ firstItem: JMTimelineItem, _ secondItem: JMTimelineItem) -> Bool {
        if firstItem.groupingID == nil || secondItem.groupingID == nil {
            return false
        }
        else if let firstGroupingID = firstItem.groupingID, let secondGroupingID = secondItem.groupingID, firstGroupingID != secondGroupingID {
            return false
        }
        else {
            return true
        }
    }
    
    private func insertAndAdjust(item newerItem: JMTimelineItem) {
        let indexPath = IndexPath(item: 0, section: grouping.historyFrontIndex)
        defer { try? manager.memoryStorage.insertItem(newerItem, to: indexPath) }
        
        newerItem.removeRenderOptions(.groupBottomMargin)
        guard let olderItem = manager.memoryStorage.item(at: indexPath) as? JMTimelineItem else { return }
        
        if let newerGroupingID = newerItem.groupingID, let olderGroupingID = olderItem.groupingID, newerGroupingID != olderGroupingID {
            olderItem.addRenderOptions(.groupBottomMargin)
            cache.resetSize(for: olderItem.UUID)
            manager.memoryStorage.reloadItem(olderItem)

            newerItem.addRenderOptions(.groupTopMargin)
        }
        else {
            olderItem.removeRenderOptions([.groupLastElement, .groupBottomMargin])
            cache.resetSize(for: olderItem.UUID)
            manager.memoryStorage.reloadItem(olderItem)
            
            newerItem.removeRenderOptions([.groupFirstElement, .groupTopMargin])
            cache.resetSize(for: newerItem.UUID)
        }
    }
}
