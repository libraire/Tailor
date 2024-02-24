import SwiftUI
import Vision

struct ContentView: View {
    @State private var originalImage: NSImage?
    @State private var croppedImage: NSImage?

    var body: some View {
        VStack {
            if let originalImage = originalImage {
                Image(nsImage: originalImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Drag, drop and crop an image here")
                    .font(.title)
                    .foregroundColor(.gray)
            }

            if let croppedImage = croppedImage {
                Image(nsImage: croppedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .onDrop(of: ["public.file-url"], isTargeted: nil) { providers -> Bool in
            if let item = providers.first {
                item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                    if let urlData = urlData as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        DispatchQueue.main.async {
                            if let image = NSImage(contentsOf: url) {
                                self.originalImage = image
                                self.cropImage(image)
                            }
                        }
                    }
                }
            }
            return true
        }
    }

    func cropImage(_ image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNDetectRectanglesRequest { request, error in
            guard let observations = request.results as? [VNRectangleObservation], let observation = observations.first else {
                return
            }

            let imageSize = CGSize(width: CGFloat(cgImage.width), height: CGFloat(cgImage.height))
            let boundingBox = VNImageRectForNormalizedRect(observation.boundingBox, Int(imageSize.width), Int(imageSize.height))

            guard let croppedCGImage = cgImage.cropping(to: boundingBox) else { return }
            let croppedImage = NSImage(cgImage: croppedCGImage, size: NSSize.zero)

            self.croppedImage = croppedImage
        }
        
        request.maximumObservations = 0
        request.minimumAspectRatio = 0.5
        request.maximumAspectRatio = 1
        request.minimumSize = 0.5
        request.quadratureTolerance = 45
        request.minimumConfidence = 0.2

        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing rectangle detection: \(error)")
        }
    }
}
