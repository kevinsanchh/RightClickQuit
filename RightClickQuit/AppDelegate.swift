// RightClickQuit AppDelegate

import Cocoa
import Accessibility

class AppDelegate: NSObject, NSApplicationDelegate {

    private var eventMonitor: Any?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // First, check if we have accessibility permissions.
        // If not, the prompt will be shown to the user.
        let checkOpt = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let accessEnabled = AXIsProcessTrustedWithOptions([checkOpt: true] as CFDictionary)

        if accessEnabled {
            print("Accessibility permissions already granted.")
            startEventMonitoring()
        } else {
            print("Accessibility permissions are not granted. Waiting for user.")
            // We'll check again periodically in case the user grants permission
            // while the app is running.
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                if AXIsProcessTrusted() {
                    self?.startEventMonitoring()
                    timer.invalidate()
                }
            }
        }
    }

    func startEventMonitoring() {
        // This monitor listens for global right-click mouse down events.
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            self?.handleRightClick(event: event)
        }
        print("Event monitor started.")
    }

    private func handleRightClick(event: NSEvent) {
        // Get mouse location in screen coordinates (origin at bottom-left).
        let mouseLocation = NSEvent.mouseLocation

        // Use the reliable Core Graphics API to get a list of all on-screen windows.
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return
        }
        
        // Find the screen containing the click to correctly convert the Y-coordinate.
        let screens = NSScreen.screens
        guard let screen = screens.first(where: { $0.frame.contains(mouseLocation) }) else { return }
        let screenHeight = screen.frame.height
        
        // Convert the mouse's bottom-left Y-coordinate to a top-left Y-coordinate.
        let convertedMousePoint = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

        // Find the topmost window under the cursor. The API returns windows from front to back.
        var targetWindow: [String: Any]?
        for window in windowList {
            // kCGWindowLayer == 0 are standard, interactive windows.
            if window[kCGWindowLayer as String] as? Int == 0 {
                guard let boundsDict = window[kCGWindowBounds as String] as? [String: CGFloat],
                      let x = boundsDict["X"], let y = boundsDict["Y"],
                      let w = boundsDict["Width"], let h = boundsDict["Height"] else { continue }
                
                let windowFrame = CGRect(x: x, y: y, width: w, height: h)
                
                // If the converted click is inside this window's frame, we've found our target.
                if windowFrame.contains(convertedMousePoint) {
                    targetWindow = window
                    break // Stop at the first (topmost) match.
                }
            }
        }
        
        guard let foundWindow = targetWindow else { return }

        // Instead of asking where the button is, we assume its location based on macOS UI standards.
        // Get the origin of the window we found.
        guard let boundsDict = foundWindow[kCGWindowBounds as String] as? [String: CGFloat],
              let windowX = boundsDict["X"],
              let windowY = boundsDict["Y"] else { return }

        // Define a generous 40x40pt "hot zone" at the top-left of the window where the close button resides.
        let closeButtonArea = CGRect(x: windowX, y: windowY, width: 40, height: 40)

        // Check if the user's click was inside this calculated hot zone.
        if closeButtonArea.contains(convertedMousePoint) {
            // If it was, get the Process ID (PID) from the window info.
            guard let pid = foundWindow[kCGWindowOwnerPID as String] as? pid_t,
                  let targetApp = NSRunningApplication(processIdentifier: pid) else { return }

            // Safety checks, then terminate.
            if targetApp.bundleIdentifier != Bundle.main.bundleIdentifier && targetApp.bundleIdentifier != "com.apple.finder" {
                targetApp.terminate()
            }
        }
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up the event monitor when the app quits
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            print("Event monitor stopped.")
        }
    }
}
