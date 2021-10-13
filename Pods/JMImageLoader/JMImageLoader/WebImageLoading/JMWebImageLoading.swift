//
//  JMWebImageLoading.swift
//  JMImageLoader
//
//  Created by macbook on 31.07.2021.
//

import UIKit

public enum JMWebImageLoadingError: Error {
    case failureResponse(statusCode: Int, error: Error?)
    case decodingError
    case unknown(Error?)
}

public protocol JMWebImageLoading: JMImageLoadingNode {
    func cancelCurrentLoading()
}
