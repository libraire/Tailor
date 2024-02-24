//
//  tailorApp.swift
//  tailor
//
//  Created by junqing pan on 2024/2/7.
//

import SwiftUI
import Cocoa
import AppKit
import Quartz
import Vision
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem:NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(named: "rectangle")
        }
        
        let menu = NSMenu()
        let captureMenuItem = NSMenuItem(title: "Capture", action: #selector(captureScreen(_:)), keyEquivalent: "c")
        menu.addItem(captureMenuItem)
        
        let selectionMenuItem = NSMenuItem(title: "Selection", action: #selector(selectionScreen(_:)), keyEquivalent: "s")
        menu.addItem(selectionMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }
    
    
    @objc func captureScreen(_ sender: NSMenuItem) {
        if(captureToClipboard()) {
            createVisionRequest(cgImage: getImageFromClipboard(),completion: completedVisionRequest)
        }
        // for debug
        // addTransparentOverlay(image: NSImage(), rectangles: [])
    }
    
    @objc func selectionScreen(_ sender: NSMenuItem) {
        if(captureSelection()) {
            createVisionRequest(cgImage: getImageFromClipboard(),completion: completedSelectionRequest)
        }
    }
}

@main
struct tailorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let hotKey = HotKey(key: .r, modifiers: [.command, .option], keyDownHandler: {
        NSApp.activate(ignoringOtherApps: true)
        if(captureToClipboard()) {
            createVisionRequest(cgImage: getImageFromClipboard(),completion: completedVisionRequest)
        }
        
    })
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
