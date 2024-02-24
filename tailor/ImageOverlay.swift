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
    private var window: NSWindow? = nil
    private var rectanges: [TailorRectangle] = []
    
    init(_ image: NSImage, _ window: NSWindow, _ rectanges: [VNRectangleObservation]?) {
        self.image = image
        self.window = window
        
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
                        RectView(image, self.window!, rect)
                    }
                }
                .foregroundColor(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { gestureLocation in
                    self.window?.close()
                }
        }.onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
                // Press Escape to close
                if nsevent.keyCode == 53 {
                    self.window?.close()
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
    
    init(_ image: NSImage, _ window: NSWindow, _ rect: TailorRectangle) {
        self.image = image
        self.window = window
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
                            .copyImageToClipboard()
                        self.window?.close()
                    }) {
                        Text("Copy")
                            .padding()
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }.alignmentGuide(HorizontalAlignment.trailing) { d in
                        d[HorizontalAlignment.trailing]
                    }
                    
                    Button(action: {
                        image.cropImage(boundingBox: rect.observation.boundingBox)?
                            .saveToFile()
                        self.window?.close()
                    }) {
                        Text("Save")
                            .padding()
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
                self.window?.close()
            }
    }
    
}
