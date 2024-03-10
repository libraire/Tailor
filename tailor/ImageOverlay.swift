//
//  ImageOverlay.swift
//  Tailor
//
//  Created by junqing pan on 2024/2/18.
//

import SwiftUI
import Vision

struct ImageOverlayView: View {
    @State private var image: NSImage
    private var rectanges: [TailorRectangle] = []
    
    init(_ image: NSImage, _ rectanges: [VNRectangleObservation]?) {
        self.image = image
        
        if let rectanges = rectanges {
            let transformProperties = CGSize.aspectFit(aspectRatio: NSScreen.main?.frame.size ?? CGSizeZero, boundingSize: NSScreen.main?.frame.size ?? CGSizeZero)
            self.rectanges = rectanges.enumerated().map({ (index,VNRectangleObservation) in
                let frame = frameForRectangle(VNRectangleObservation, withTransformProperties: transformProperties)
                let px = frame.origin.x+frame.width/2
                let py = NSScreen.main!.frame.size.height-(frame.origin.y+frame.height/2)
                return TailorRectangle(id: index, observation: VNRectangleObservation, frame:frame,positionX: px,positionY: py)
            })
        }
    }
    
    var body: some View {
        ZStack {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Rectangle()
                .overlay {
                    ForEach(self.rectanges) { rect in
                        RectView(image, rect)
                    }
                }
                .foregroundColor(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { gestureLocation in
                    
                    
                    WindowManager.shared.closeWindow()
                }
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                // Press Escape to close
                if nsevent.keyCode == 53 {
                    WindowManager.shared.closeWindow()
                }
                return nsevent
            }
        }
    }
}


struct RectView : View {
    
    private var rect: TailorRectangle
    private var image: NSImage
    @StateObject var observableHoveringObject: ObservableHoveringObject = ObservableHoveringObject.shared
    private var window: NSWindow? = nil
    
    init(_ image: NSImage, _ rect: TailorRectangle) {
        self.image = image
        self.rect = rect
    }
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            Rectangle()
                .border(Color.red, width: 2)
                .frame(width: rect.frame.width, height: rect.frame.height)
                .foregroundColor(observableHoveringObject.isHovering(index: self.rect.id) ? Color.red.opacity(0.5) : .clear)
            
            if (observableHoveringObject.isHovering(index: self.rect.id)) {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        image.cropImage(boundingBox: rect.observation.boundingBox)?
                            .preview()
                        WindowManager.shared.closeWindow()
                    }) {
                        Text("Preview")
                            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.alignmentGuide(HorizontalAlignment.trailing) { d in
                        d[HorizontalAlignment.trailing]
                    }
                    
                    Button(action: {
                        image.cropImage(boundingBox: rect.observation.boundingBox)?
                            .copyImageToClipboard()
                        WindowManager.shared.closeWindow()
                    }) {
                        Text("Copy")
                            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.alignmentGuide(HorizontalAlignment.trailing) { d in
                        d[HorizontalAlignment.trailing]
                    }
                    
                    Button(action: {
                        image.cropImage(boundingBox: rect.observation.boundingBox)?
                            .saveToFile()
                        WindowManager.shared.closeWindow()
                    }) {
                        Text("Save")
                            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.alignmentGuide(HorizontalAlignment.trailing) { d in
                        d[HorizontalAlignment.trailing]
                    }
                }.padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                
            }
            
        }.border(Color.red, width: 2)
            .frame(width: rect.frame.width, height: rect.frame.height)
            .onHover { hovering in
                observableHoveringObject.sign(self.rect.id, hoverValue: hovering)
            }
            .position(x:rect.positionX,y:rect.positionY)
            .onTapGesture {
                WindowManager.shared.closeWindow()
            }
    }
    
}
