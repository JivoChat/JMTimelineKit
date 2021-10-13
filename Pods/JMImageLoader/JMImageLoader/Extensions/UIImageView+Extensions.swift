//
//  UIImageView+Extensions.swift
//  JMImageLoader
//
//  Created by macbook on 03.08.2021.
//

import UIKit

extension UIImageView: JMImageViewImageLoading {
    @discardableResult
    public func jmLoadImage(with url: URL, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        let IMAGE_CACHE_MEMORY_LIMIT = 1024 * 1024 * 50
        
        let defaultLoadingStrategy = ImageLoadingStrategyFactory.defaultShared(withImageCacheMemoryLimit: IMAGE_CACHE_MEMORY_LIMIT)
        let task = defaultLoadingStrategy.load(with: url) { [weak self] result in
            switch result {
            case let .success(image):
                self?.image = image
                
            case .failure:
                break
            }
            
            completion?(result)
        }
        
        return task
    }
    
    @discardableResult
    public func jmLoadImage(with url: URL, usingStrategy loadingStrategy: JMImageLoading, completion: ((Result<UIImage, Error>) -> Void)? = nil) -> JMImageLoadingCancellable {
        let task = loadingStrategy.load(with: url) { [weak self] result in
            switch result {
            case let .success(image):
                self?.image = image
                
            case .failure:
                break
            }
            
            completion?(result)
        }
        
        return task
    }
}
