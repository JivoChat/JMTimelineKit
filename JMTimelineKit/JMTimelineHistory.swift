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
    private var earliestItemsMap = [Int: JMTimelineItem]()
    private var registeredFooterModels = [JMTimelineItem]()
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
            return self?.grouping.group(forSection: section)
        }

        manager.memoryStorage.supplementaryModelProvider = { [weak self] _, indexPath in
            guard let `self` = self else { return nil }
            let index = indexPath.section - self.grouping.historyFrontIndex
            return self.registeredFooterModels.indices.contains(index)
                ? self.registeredFooterModels[index]
                : nil
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

    public func populate(withItems items: [JMTimelineItem]) {
        items.forEach { item in
            if let existingGroupIndex = grouping.section(for: item.date.withoutTime()),
               let groupItems = manager.memoryStorage.items(inSection: existingGroupIndex)?.compactMap({ $0 as? JMTimelineItem }) {
                if let borderingItemsPlacement = borderingItemsPlacement(forItem: item, insertingToGroupWithItems: groupItems) {
                    configureMargins(
                        forItems: [
                            borderingItemsPlacement.laterItemPlacement?.item,
                            item,
                            borderingItemsPlacement.earlierItemPlacement.item
                        ].compactMap { $0 },
                        usingOption: borderingItemsPlacement.laterItemPlacement == nil
                            ? .itemsStartIsGroupLateBound
                            : .itemsBoundsIsNotGroupBounds
                    )
                    let indexPathToInsertAt = IndexPath(
                        item: borderingItemsPlacement.earlierItemPlacement.index,
                        section: existingGroupIndex
                    )
                    do {
                        try manager.memoryStorage.insertItem(item, to: indexPathToInsertAt)
                    } catch {
                        print("\n\nMemoryStorage.insertItem(_:to:) instance method throwed an exception: \(error.localizedDescription)\n\n")
                    }
                } else {
                    configureMargins(forItems: [item], usingOption: .itemsEndIsGroupEarlyBound)
                    let indexPathToAppendItem = IndexPath(item: groupItems.count, section: existingGroupIndex)
                    do {
                        try manager.memoryStorage.insertItem(item, to: indexPathToAppendItem)
                    } catch {
                        print("\n\nMemoryStorage.insertItem(_:to:) instance method throwed an exception: \(error.localizedDescription)\n\n")
                    }
                }
            } else {
                guard let newGroupIndex = grouping.grow(date: item.date.withoutTime()) else { return print("\n\nThere is an internal bug occured while populating timeline with new items: JMTimelineGrouping.section(for:) method didn't find any existing group for item date (\(item.date.withoutTime())), but JMTimelineGrouping.grow(date:) found.\n\n") }
                configureMargins(forItems: [item], usingOption: .itemsBoundsIsGroupBounds)
                
                self.registeredFooterModels.insert(self.factory.generateItem(for: item.date.withoutTime()), at: newGroupIndex - self.grouping.historyFrontIndex)
                
                let section = SectionModel()
                section.setItems([item])
                manager.memoryStorage.insertSection(section, atIndex: newGroupIndex)
            }
            
            registeredItemIDs.insert(item.uid)
        }
    }
    
    private func borderingItemsPlacement(forItem item: JMTimelineItem, insertingToGroupWithItems groupItems: [JMTimelineItem]) -> (earlierItemPlacement: GroupItemPlacement, laterItemPlacement: GroupItemPlacement?)? {
        // earlierIndexItemPair.element will move to next index in section after item will be inserted to earlierIndexItemPair.offset
        if let earlierIndexItemPair = groupItems
            .enumerated()
            .first(where: { _, groupItem in
                return groupItem.date <= item.date
            }) {
            let index = earlierIndexItemPair.offset
            let earlierItem = earlierIndexItemPair.element
            let laterItemIndex = index - 1
            let laterItem = laterItemIndex >= 0 ? groupItems[laterItemIndex] : nil
            
            let earlierItemPlacement = GroupItemPlacement(index: index, item: earlierItem)
            let laterItemPlacement = laterItem.flatMap {
                GroupItemPlacement(index: laterItemIndex, item: $0)
            }
            
            return (
                earlierItemPlacement: earlierItemPlacement,
                laterItemPlacement: laterItemPlacement
            )
        } else {
            return nil
        }
    }
    
    /// Adds or removes rendering options for passed JMTimelineItem objects using one of several item bounds options
    /// - Parameters:
    ///  - items: Array of JMTimelineItem objects to which the rendering options changes is applied. Must be passed in the same order as they arranged in its own CollectionView section.
    ///  - option: an option specifying the rendering options applying to bound items way.

    private func configureMargins(forItems items: [JMTimelineItem], usingOption option: MarginsConfigurationOption) {
        _ = items.reduce(nil) { (laterItem: JMTimelineItem?, item: JMTimelineItem) -> JMTimelineItem in
            guard let laterItem = laterItem else { return item }
            
            if laterItem.groupingID == item.groupingID {
                laterItem.removeLayoutOptions([.groupTopMargin, .groupFirstElement])
                item.removeLayoutOptions([.groupBottomMargin, .groupLastElement])
            } else {
                laterItem.addLayoutOptions([.groupTopMargin, .groupFirstElement])
                item.addLayoutOptions([.groupBottomMargin, .groupLastElement])
            }
            
            cache.resetSize(for: laterItem.uid)
            cache.resetSize(for: item.uid)
            manager.memoryStorage.reloadItem(laterItem)
            manager.memoryStorage.reloadItem(item)
            
            return item
        }
        
        switch option {
        case .itemsStartIsGroupLateBound:
            guard let latestItem = items.first else { return }
            latestItem.addLayoutOptions([.groupBottomMargin, .groupLastElement])
            cache.resetSize(for: latestItem.uid)
            manager.memoryStorage.reloadItem(latestItem)
            
        case .itemsEndIsGroupEarlyBound:
            guard let earliestItem = items.last else { return }
            earliestItem.addLayoutOptions([.groupTopMargin, .groupFirstElement])
            cache.resetSize(for: earliestItem.uid)
            manager.memoryStorage.reloadItem(earliestItem)
            
        case .itemsBoundsIsGroupBounds:
            guard let earliestItem = items.last, let latestItem = items.first else { return }
            
            earliestItem.addLayoutOptions([.groupTopMargin, .groupFirstElement])
            cache.resetSize(for: earliestItem.uid)
            manager.memoryStorage.reloadItem(earliestItem)
            
            latestItem.addLayoutOptions([.groupBottomMargin, .groupLastElement])
            cache.resetSize(for: latestItem.uid)
            manager.memoryStorage.reloadItem(latestItem)
            
        case .itemsBoundsIsNotGroupBounds: break
            
        default: break
        }
    }

    public func append(items: [JMTimelineItem]) {
//        manager.memoryStorage.defersDatasourceUpdates = false
//        defer { manager.memoryStorage.defersDatasourceUpdates = true }

        manager.memoryStorage.performUpdates {
            items.forEach { item in
                let messageClearDate = item.date.withoutTime()

                if let groupIndex = self.grouping.grow(date: messageClearDate) {
                    let footerIndex = groupIndex - grouping.historyFrontIndex
                    registeredFooterModels.insert(factory.generateItem(for: messageClearDate), at: footerIndex)
                    
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

                if let groupIndex = grouping.section(for: messageClearDate) {
                    prependAndAdjust(context: context, item: item, into: groupIndex)
                }
                else if let groupIndex = grouping.grow(date: messageClearDate) {
                    let footerIndex = groupIndex - grouping.historyFrontIndex
                    registeredFooterModels.insert(factory.generateItem(for: messageClearDate), at: footerIndex)
                    
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
        guard let itemToRemove = item(byUUID: UUID) as? JMTimelineItem else { return}
        try? manager.memoryStorage.removeItem(itemToRemove)
        
        guard
            let itemToRemoveGroupIndex = grouping.section(for: itemToRemove.date.withoutTime()),
            let groupItems = manager.memoryStorage.items(inSection: itemToRemoveGroupIndex)?
                .compactMap({ $0 as? JMTimelineItem })
        else { return }
        
        var marginsConfigurationOption: MarginsConfigurationOption = .itemsBoundsIsNotGroupBounds
        var itemsToConfigure: [JMTimelineItem] = []
        
        if let borderingItemsPlacement = borderingItemsPlacement(forItem: itemToRemove, insertingToGroupWithItems: groupItems) {
            if groupItems.last == borderingItemsPlacement.earlierItemPlacement.item {
                marginsConfigurationOption.insert(.itemsEndIsGroupEarlyBound)
            }
            if groupItems.first == borderingItemsPlacement.laterItemPlacement?.item || groupItems.first == borderingItemsPlacement.earlierItemPlacement.item {
                marginsConfigurationOption.insert(.itemsStartIsGroupLateBound)
            }
            itemsToConfigure += [
                borderingItemsPlacement.laterItemPlacement?.item,
                borderingItemsPlacement.earlierItemPlacement.item
            ].compactMap { $0 }
        }
        else {
            marginsConfigurationOption = .itemsEndIsGroupEarlyBound
            groupItems.last.flatMap { itemsToConfigure.append($0) }
        }
        
        configureMargins(forItems: itemsToConfigure, usingOption: marginsConfigurationOption)
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
        if let firstGroupingID = firstItem.groupingID, let secondGroupingID = secondItem.groupingID {
            return (firstGroupingID == secondGroupingID)
        }
        else {
            return false
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
}

extension JMTimelineHistory {
    struct MarginsConfigurationOption: OptionSet {
        let rawValue: Int
        
        static let itemsStartIsGroupLateBound = Self(rawValue: 1 << 0)
        static let itemsEndIsGroupEarlyBound = Self(rawValue: 1 << 1)
        static let itemsBoundsIsGroupBounds = Self(rawValue: ~0)
        static let itemsBoundsIsNotGroupBounds = Self(rawValue: 0)
    }
    
    struct GroupItemPlacement {
        let index: Int
        let item: JMTimelineItem
    }
}
