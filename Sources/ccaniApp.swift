import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: NSPanel?
    var server: AnyObject?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Will be wired up in Task 9
    }
}

@main
struct CcaniApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
