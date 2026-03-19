import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: DynamicIslandPanel?
    var server: HookServer?
    let sessionManager = SessionManager()
    private var clickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[ccani] App launched")
        setupPanel()
        print("[ccani] Panel set up")
        startServer()
        print("[ccani] Server started")
        setupClickOutsideMonitor()
        print("[ccani] Ready")
    }

    func applicationWillTerminate(_ notification: Notification) {
        server?.stop()
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    private func setupPanel() {
        let contentView = DynamicIslandContent(sessionManager: sessionManager)
        let hostView = SizeTrackingHostingView(rootView: contentView)
        hostView.sizingOptions = [.intrinsicContentSize]

        let panel = DynamicIslandPanel(contentView: hostView)
        hostView.onSizeChange = { [weak panel] size in
            panel?.updateFrameForContentSize(size)
        }
        panel.orderFrontRegardless()
        self.panel = panel
    }

    private func startServer() {
        let server = HookServer { [weak self] event in
            self?.sessionManager.handleEvent(event)
        }
        do {
            try server.start()
            self.server = server

            // Defer hooks setup to avoid blocking app launch with modal dialog
            let port = server.port
            DispatchQueue.main.async {
                let configurator = HooksConfigurator()
                if configurator.needsSetup() {
                    configurator.promptAndInstall(port: port)
                }
            }
        } catch HookServer.ServerError.anotherInstanceRunning {
            print("Another ccani instance is already running. Exiting.")
            NSApp.terminate(nil)
        } catch {
            print("Failed to start server: \(error)")
        }
    }

    private func setupClickOutsideMonitor() {
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { _ in
            NotificationCenter.default.post(name: .ccaniClickOutside, object: nil)
        }
    }
}

extension Notification.Name {
    static let ccaniClickOutside = Notification.Name("ccaniClickOutside")
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

struct DynamicIslandContent: View {
    let sessionManager: SessionManager

    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Capsule always visible at top
            CapsuleView(
                session: sessionManager.activeSession,
                sessionCount: sessionManager.sessions.count
            )

            // Expanded detail grows below capsule
            if isExpanded {
                ExpandedDetailView(
                    session: sessionManager.activeSession,
                    sessions: sessionManager.sortedSessions,
                    onSelectSession: { id in
                        sessionManager.selectSession(id)
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
        }
        .fixedSize()
        .clipped()
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                isExpanded = hovering
            }
        }
    }
}
