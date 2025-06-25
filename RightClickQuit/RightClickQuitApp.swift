import SwiftUI

@main
struct RightClickQuitApp: App {
    // This connects our AppDelegate to the SwiftUI app lifecycle.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // This creates an icon in the system menu bar instead of a window.
        MenuBarExtra {
            Button("Quit RightClickQuit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            // You can use an SF Symbol for the menu bar icon.
            Image(systemName: "q.circle.fill")
        }
    }
}
