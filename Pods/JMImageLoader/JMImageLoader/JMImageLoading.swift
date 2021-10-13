//
//  JMImageLoading.swift
//  JMImageLoader
//
//  Created by macbook on 02.08.2021.
//

import UIKit

public protocol JMImageLoading {
    @discardableResult
    func load(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> JMImageLoadingCancellable
}
