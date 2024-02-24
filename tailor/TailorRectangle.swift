//
//  TailorRectangle.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import Foundation
import Vision


struct TailorRectangle : Identifiable {
    let id: Int
    let observation: VNRectangleObservation
    let frame: CGRect
    let positionX: CGFloat
    let positionY: CGFloat
}
