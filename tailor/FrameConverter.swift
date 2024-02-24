//
//  FrameConverter.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import Foundation
import Vision

func frameForRectangle(_ rectangle: VNRectangleObservation, withTransformProperties properties: (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)) -> NSRect {
    // Use aspect fit to determine scaling and X & Y offsets
    let transform = CGAffineTransform.identity
        .translatedBy(x: properties.xOffset, y: properties.yOffset)
        .scaledBy(x: properties.size.width, y: properties.size.height)
    
    // Convert normalized coordinates to display coordinates
    let convertedTopLeft = rectangle.topLeft.applying(transform)
    let convertedTopRight = rectangle.topRight.applying(transform)
    let convertedBottomLeft = rectangle.bottomLeft.applying(transform)
    let convertedBottomRight = rectangle.bottomRight.applying(transform)
    
    // Calculate bounds of bounding box
    let minX = min(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
    let maxX = max(convertedTopLeft.x, convertedTopRight.x, convertedBottomLeft.x, convertedBottomRight.x)
    let minY = min(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
    let maxY = max(convertedTopLeft.y, convertedTopRight.y, convertedBottomLeft.y, convertedBottomRight.y)
    let frame = NSRect(x: minX , y: minY, width: maxX - minX, height: maxY - minY)
    return frame
}
