//
//  Utility.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import AppKit
import Vision
import SwiftUI

public func addTransparentOverlay(image: NSImage, rectangles : [VNRectangleObservation]) {
    let overlayView = ImageOverlayView(image, rectangles)
    WindowManager.shared.showContentView(contentView: NSHostingView(rootView: overlayView))
}


func convertCGImageToNSImage(_ cgImage: CGImage) -> NSImage {
    let size = NSSize(width: cgImage.width, height: cgImage.height)
    return NSImage(cgImage: cgImage, size: size)
}

func getImageFromClipboard()-> CGImage? {
    let pasteboard = NSPasteboard.general
    guard pasteboard.canReadItem(withDataConformingToTypes: NSImage.imageTypes)
    else {return nil}
    
    guard let image = NSImage(pasteboard: pasteboard) else {
        return nil
    }
    
    return image.toCGImage()
}

func createVisionRequest(cgImage: CGImage?, completion: @escaping (VNRequest?, Error?, CGImage) -> Void) {
    // https://www.dabblingbadger.com/blog/2020/2/10/rectangle-detection
    guard let cgImage = cgImage else {
        return
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNDetectRectanglesRequest { request, error in
        completion(request, error, cgImage)
    }
    
    request.maximumObservations = 0
    request.minimumAspectRatio = 0.5
    request.maximumAspectRatio = 1
    request.minimumSize = 0.1
    request.quadratureTolerance = 45
    request.minimumConfidence = 0.2
    
    DispatchQueue.global().async {
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error: Rectangle detection failed - vision request failed.")
        }
    }
}

func completedVisionRequest(_ request: VNRequest?, error: Error?, image: CGImage) {
    guard let rectangles = request?.results as? [VNRectangleObservation] else {
        guard let error = error else { return }
        print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
        return
    }
    
    if (rectangles.isEmpty) {
        // Try with selection mode and match the largest rectangle by default
        if(captureSelection()) {
            createVisionRequest(cgImage: getImageFromClipboard(),completion: completedSelectionRequest)
        }
        return
    }
    
    DispatchQueue.main.async {
        addTransparentOverlay(image: convertCGImageToNSImage(image), rectangles: rectangles)
    }
    
}

func completedSelectionRequest(_ request: VNRequest?, error: Error?, image: CGImage) {
    guard let rectangles = request?.results as? [VNRectangleObservation] else {
        guard let error = error else { return }
        print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
        return
    }
    
    if (rectangles.isEmpty) {
        return
    }
    
    if (rectangles.count  == 1) {
        
        DispatchQueue.main.async {
            addTransparentOverlay(image: convertCGImageToNSImage(image), rectangles: rectangles)
        }
//        convertCGImageToNSImage(image).cropImage(boundingBox: rectangles[0].boundingBox)?.copyImageToClipboard()
        return
    }
    
    let one = rectangles.reduce(rectangles.first!) { largerOne, next in
        let size1 = largerOne.boundingBox.width * largerOne.boundingBox.height
        let size2 = next.boundingBox.width * next.boundingBox.height
        if(size1 > size2) {
            return largerOne
        }
        return next
    }
    
    
    DispatchQueue.main.async {
        addTransparentOverlay(image: convertCGImageToNSImage(image), rectangles: [one])
    }
    
//    convertCGImageToNSImage(image).cropImage(boundingBox: boundingBox)?.copyImageToClipboard()
    
}


func completedPreviewRequest(_ request: VNRequest?, error: Error?, image: CGImage) {
    guard let rectangles = request?.results as? [VNRectangleObservation] else {
        guard let error = error else { return }
        print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
        return
    }
    
    if (rectangles.isEmpty) {
        return
    }
    
    if (rectangles.count  == 1) {
        convertCGImageToNSImage(image).preview()
        return
    }
    
    let one = rectangles.reduce(rectangles.first!) { largerOne, next in
        let size1 = largerOne.boundingBox.width * largerOne.boundingBox.height
        let size2 = next.boundingBox.width * next.boundingBox.height
        if(size1 > size2) {
            return largerOne
        }
        return next
    }
    
    convertCGImageToNSImage(image).cropImage(boundingBox: one.boundingBox)?.preview()
    
}

