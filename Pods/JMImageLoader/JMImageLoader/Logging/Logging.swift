//
//  Logging.swift
//  JMImageLoader
//
//  Created by macbook on 03.08.2021.
//

import Foundation

enum LoggingLevel {
    case full
//    case compact
    case silent
}

protocol Logging {
    func log(_ message: String)
}
