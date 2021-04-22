//
//  JMTimelineCompositeLocationBlock.swift
//  JivoMobile
//
//  Created by Stan Potemkin on 25/09/2018.
//  Copyright © 2018 JivoSite. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public struct JMTimelineCompositeLocationBlockStyle: JMTimelineStyle {
    let ratio: CGFloat

    public init(ratio: CGFloat) {
        self.ratio = ratio
    }
}

final class JMTimelineCompositeLocationBlock: MKMapView, JMTimelineBlock {
    private var coordinate: CLLocationCoordinate2D?
    private var ratio = CGFloat(0)

    private weak var interactor: JMTimelineInteractor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isScrollEnabled = false
        isZoomEnabled = false
        clipsToBounds = true
        isUserInteractionEnabled = true
        
        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleTap))
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func link(provider: JMTimelineProvider, interactor: JMTimelineInteractor) {
        self.interactor = interactor
    }
    
    func configure(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        
        mapType = .standard
        
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
    }
    
    func apply(style: JMTimelineStyle) {
        let style = style.convert(to: JMTimelineCompositeLocationBlockStyle.self)

        ratio = style.ratio
    }

    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) -> Bool {
        return false
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = size.width * ratio
        return CGSize(width: size.width, height: height)
    }

    @objc private func handleTap() {
        guard let coordinate = coordinate else { return }
        interactor.requestLocation(coordinate: coordinate)
    }
}
