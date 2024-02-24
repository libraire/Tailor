import Vision

func detectEdgesAndCrop(image: NSImage) -> NSImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    
    // Create a request handler for the image
    let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    
    // Create a Vision request for edge detection
    let edgeDetectionRequest = VNDetectEdgesRequest { request, error in
        guard let observations = request.results as? [VNEdgeObservation], let observation = observations.first else {
            return
        }

        // Crop the image based on the detected edge
        let croppedImage = ciImage.cropped(to: observation.boundingBox)
        
        // Convert the cropped CIImage back to NSImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(croppedImage, from: croppedImage.extent) else { return }
        let croppedNSImage = NSImage(cgImage: cgImage)
        
        // Perform any additional processing or return the cropped image
        // ...
        
    }
    
    // Perform the edge detection request
    do {
        try requestHandler.perform([edgeDetectionRequest])
    } catch {
        print("Error performing edge detection: \(error)")
        return nil
    }
    
    // Return the cropped image
    return croppedNSImage
}
