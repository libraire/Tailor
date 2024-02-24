import Cocoa

public func captureSelection() -> Bool {
    let task = Process()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = ["-cxs"]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus == 0
}

public func captureToClipboard() -> Bool {    
    let task = Process()
    task.launchPath = "/usr/sbin/screencapture"
    task.arguments = ["-cxa"]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus == 0
}
