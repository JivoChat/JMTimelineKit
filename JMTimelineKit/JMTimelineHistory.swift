//
//  JMTimelineHistory.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 16/05/2017.
//  Copyright © 2017 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import JFCollectionViewManager
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
    private var earliestItemsMap = [Int: JMTimelineItem]()
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
                guard uuid == item.uid else { continue }
                return item
            }
        }

        return nil
    }

    public func fill(with items: [JMTimelineItem]) {
        earliestItemsMap.removeAll()
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

    public func insert(items: [JMTimelineItem], after itemBeforeInsertion: JMTimelineItem?) {
        manager.memoryStorage.performUpdates {
            configureMarginsFor(items, placedAfter: itemBeforeInsertion)

            items.forEach { item in
                let itemDate = item.date.withoutTime()

                if let existingGroupIndex = grouping.group(for: itemDate) {
//                    let indexPathToInsertItem = recentItemsMap[existingGroupIndex].flatMap { $0.count + 1 } ?? 0
//                    let indexPathToInsert = IndexPath(item: indexPathToInsertItem, section: existingGroupIndex)
//                    try? manager.memoryStorage.insertItem(item, to: indexPathToInsert)
                } else {
                    guard let newGroupIndex = grouping.grow(date: itemDate) else { return }

                    let footerIndexPath = IndexPath(item: 0, section: newGroupIndex)
                    registeredHeaderModels[newGroupIndex] = itemDate
                    registeredFooterModels[footerIndexPath] = factory.generateDateItem(date: itemDate)

                    let model = SectionModel()
                    model.setItems([item])
//                    recentItemsMap[newGroupIndex]?.append(item)
                    manager.memoryStorage.insertSection(model, atIndex: grouping.historyFrontIndex)
                }

                let indexPathToInsert = manager.memoryStorage.indexPath(forItem: itemBeforeInsertion) ?? IndexPath(item: 0, section: grouping.historyFrontIndex)

                try? manager.memoryStorage.insertItem(item, to: indexPathToInsert)

                registeredItemIDs.insert(item.uid)
            }
        }
    }

    public func append(items: [JMTimelineItem]) {
        manager.memoryStorage.defersDatasourceUpdates = false
        defer { manager.memoryStorage.defersDatasourceUpdates = true }

        manager.memoryStorage.performUpdates {
            items.forEach { item in
                let messageClearDate = item.date.withoutTime()

                if let groupIndex = self.grouping.grow(date: messageClearDate) {
                    let footerIndexPath = IndexPath(item: 0, section: groupIndex)
                    self.registeredHeaderModels[groupIndex] = messageClearDate
                    self.registeredFooterModels[footerIndexPath] = self.factory.generateDateItem(date: messageClearDate)

                    let model = SectionModel()
                    model.setItems([item])
                    self.manager.memoryStorage.insertSection(model, atIndex: self.grouping.historyFrontIndex)
                }
                else {
                    self.insertAndAdjust(item: item)
                }

                self.registeredItemIDs.insert(item.uid)
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
                if registeredItemIDs.contains(item.uid) {
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
                guard UUID == item.uid else { continue }

                replacingItem.removeLayoutOptions(.allOptions)
                replacingItem.addLayoutOptions(item.layoutOptions)
                try? manager.memoryStorage.replaceItem(item, with: replacingItem)

                return
            }
        }
    }

    public func removeItem(byUUID UUID: String) {
        for section in manager.memoryStorage.sections {
            for index in 0 ..< section.numberOfItems {
                guard let item = section.item(at: index) as? JMTimelineItem else { return }
                guard UUID == item.uid else { continue }

                let nextIndex = index - 1
                if item.layoutOptions.contains(.groupFirstElement), index > 0, let nextItem = section.item(at: nextIndex) as? JMTimelineItem, item.groupingID == nextItem.groupingID {
                    nextItem.removeLayoutOptions(nextItem.layoutOptions)
                    nextItem.addLayoutOptions(item.layoutOptions)
                    cache.resetSize(for: nextItem.uid)
                    manager.memoryStorage.reloadItem(nextItem)
                }

                try? manager.memoryStorage.removeItem(item)

                return
            }
        }
    }

    private func prependAndAdjust(context: JMTimelineHistoryContext, item: JMTimelineItem, into groupIndex: Int) {
        if let newerItem = earliestItemsMap[groupIndex] {
            if item.date <= newerItem.date {
                adjustAfterPrepend(context: context, olderItem: item, newerItem: newerItem)
                earliestItemsMap[groupIndex] = item
            }
            else {
                adjustAfterPrepend(context: context, olderItem: newerItem, newerItem: item)
            }
        }
        else {
            item.removeLayoutOptions([.groupBottomMargin])
            earliestItemsMap[groupIndex] = item
        }

        manager.memoryStorage.addItem(item, toSection: groupIndex)
        registeredItemIDs.insert(item.uid)
    }

    private func adjustAfterPrepend(context: JMTimelineHistoryContext, olderItem: JMTimelineItem, newerItem: JMTimelineItem) {
        guard belongToSameGroup(olderItem, newerItem) else {
            return
        }

        newerItem.removeLayoutOptions([.groupTopMargin, .groupFirstElement])
        olderItem.removeLayoutOptions([.groupLastElement, .groupBottomMargin])

        if context.shouldResetCache {
            cache.resetSize(for: newerItem.uid)
            cache.resetSize(for: olderItem.uid)
            context.shouldResetCache = false
        }
    }

    private func belongToSameGroup(_ firstItem: JMTimelineItem, _ secondItem: JMTimelineItem) -> Bool {
        if firstItem.groupingID == nil || secondItem.groupingID == nil {
            return false
        }
        else if let firstGroupingID = firstItem.groupingID, let secondGroupingID = secondItem.groupingID {
            return (firstGroupingID == secondGroupingID)
        }
        else {
            return true
        }
    }

    private func insertAndAdjust(item newerItem: JMTimelineItem) {
        let indexPath = IndexPath(item: 0, section: grouping.historyFrontIndex)
        defer { try? manager.memoryStorage.insertItem(newerItem, to: indexPath) }

        newerItem.removeLayoutOptions(.groupBottomMargin)
        guard let olderItem = manager.memoryStorage.item(at: indexPath) as? JMTimelineItem else { return }

        if let newerGroupingID = newerItem.groupingID, let olderGroupingID = olderItem.groupingID, newerGroupingID != olderGroupingID {
            olderItem.addLayoutOptions(.groupBottomMargin)
            cache.resetSize(for: olderItem.uid)
            manager.memoryStorage.reloadItem(olderItem)

            newerItem.addLayoutOptions(.groupTopMargin)
        }
        else {
            olderItem.removeLayoutOptions([.groupLastElement, .groupBottomMargin])
            cache.resetSize(for: olderItem.uid)
            manager.memoryStorage.reloadItem(olderItem)

            newerItem.removeLayoutOptions([.groupFirstElement, .groupTopMargin])
            cache.resetSize(for: newerItem.uid)
        }
    }

    private func configureMarginsFor(_ items: [JMTimelineItem], placedAfter itemBeforeCollection: JMTimelineItem? = nil) {
        let itemAfterCollection = itemBeforeCollection.flatMap { itemInSectionDistant(from: $0, at: -1) }
        let itemsWithNeighbours = ([itemBeforeCollection] + items + [itemAfterCollection]).compactMap { $0 }

        _ = itemsWithNeighbours.reduce(items.first, { previousItem, item in
            configureMarginsFor(item, placedAfter: previousItem)
            return item
        })
    }

    private func configureMarginsFor(_ item: JMTimelineItem, placedAfter itemBefore: JMTimelineItem?) {
        if let itemBefore = itemBefore {
            if item.groupingID == itemBefore.groupingID {
                item.removeLayoutOptions([.groupTopMargin, .groupFirstElement])
                itemBefore.removeLayoutOptions([.groupBottomMargin, .groupLastElement])
            } else {
                item.addLayoutOptions(.groupTopMargin)
                itemBefore.addLayoutOptions(.groupBottomMargin)
            }
        } else {
            item.removeLayoutOptions(.groupTopMargin)
            item.addLayoutOptions(.groupFirstElement)
            cache.resetSize(for: item.uid)
        }

        cache.resetSize(for: item.uid)
        cache.resetSize(for: itemBefore?.uid ?? String())
        manager.memoryStorage.reloadItem(itemBefore)
    }

    /// Returns an item distant from the given item at specified indexPath rows.
    /// - Parameters:
    ///   - item: The item from which desired item is distant.
    ///   - distance: Difference between indexPath rows of items. Positive value is for distant item before the item in parameter and vice versa. If it zero, then passed item will be return.
    /// - Returns: JMTimelineItem if distant item was found and nil if distant item doesn't exist.

    private func itemInSectionDistant(from item: JMTimelineItem, at distance: Int) -> JMTimelineItem? {
        let distantItem = manager.memoryStorage.indexPath(forItem: item)
            .flatMap { itemIndexPath in
                let distantItemIndexPathRow = itemIndexPath.item + distance
                guard distantItemIndexPathRow >= 0 else { return nil }
                return IndexPath(item: distantItemIndexPathRow, section: itemIndexPath.section)
            }
            .flatMap { distantItemIndexPath in
                manager.memoryStorage.item(at: distantItemIndexPath) as? JMTimelineItem
            }

        return distantItem
    }
}
