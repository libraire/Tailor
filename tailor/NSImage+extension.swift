//
//  NSImage+extension.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import Cocoa


extension NSImage {
    
    func toCGImage() -> CGImage? {
        if let imageData = tiffRepresentation,
           let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) {
            let options: [NSString: Any] = [
                kCGImageSourceShouldCache: false,
                kCGImageSourceShouldAllowFloat: true
            ]
            return CGImageSourceCreateImageAtIndex(sourceData, 0, options as CFDictionary)
        }
        return nil
    }
    
    func saveToFile(){
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = "Tailor-\(Date().timeIntervalSince1970).jpg"
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                    print("Failed to get CGImage from the image.")
                    return
                }
                
                let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
                
                if let imageData = bitmapRep.representation(using: .jpeg, properties: [:]) {
                    do {
                        try imageData.write(to: url)
                        print("Image saved successfully at: \(url.path)")
                    } catch {
                        print("Failed to save the image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func cropImage(boundingBox: CGRect) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            print("Failed to get CGImage from the image.")
            return nil
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        // Convert the bounding box to image coordinates
        let frame = CGRect(x: boundingBox.origin.x * imageSize.width,
                           y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
                           width: boundingBox.size.width * imageSize.width,
                           height: boundingBox.size.height * imageSize.height)
        
        
        guard let croppedCGImage = cgImage.cropping(to: frame) else { return nil }
        let croppedImage = NSImage(cgImage: croppedCGImage, size: frame.size)
        
        return croppedImage
    }
    
    func copyImageToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Create a TIFF representation of the image
        guard let tiffData = self.tiffRepresentation else {
            print("Failed to create TIFF representation of the image")
            return
        }
        
        // Create an NSPasteboardItem and set the TIFF data on it
        let item = NSPasteboardItem()
        item.setData(tiffData, forType: .tiff)
        // Set the NSPasteboardItem on the general pasteboard
        pasteboard.writeObjects([item])
    }
    
}
