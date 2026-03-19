import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var panel: DynamicIslandPanel?
    var server: HookServer?
    let sessionManager = SessionManager()
    private var clickMonitor: Any?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("[ccani] App launched")
        setupPanel()
        print("[ccani] Panel set up")
        startServer()
        print("[ccani] Server started")
        setupClickOutsideMonitor()
        setupStatusItem()
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

    private func setupStatusItem() {
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sparkle", accessibilityDescription: "ccani")
        }

        let menu = NSMenu()
        menu.delegate = self

        let showItem = NSMenuItem(title: "Show/Hide Panel", action: #selector(togglePanel), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)

        menu.addItem(NSMenuItem.separator())

        // Pin expanded
        let pinItem = NSMenuItem(title: "Keep Expanded", action: #selector(togglePinExpanded(_:)), keyEquivalent: "")
        pinItem.target = self
        pinItem.tag = 100
        menu.addItem(pinItem)

        menu.addItem(NSMenuItem.separator())

        // Position submenu
        let posMenu = NSMenu()
        for pos in PanelPosition.allCases {
            let item = NSMenuItem(title: pos.displayName, action: #selector(changePosition(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = pos.rawValue
            posMenu.addItem(item)
        }
        let posItem = NSMenuItem(title: "Position", action: nil, keyEquivalent: "")
        posItem.submenu = posMenu
        menu.addItem(posItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit ccani", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        self.statusItem = statusItem
    }

    @objc private func togglePanel() {
        guard let panel = panel else { return }
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFrontRegardless()
        }
    }

    @objc private func togglePinExpanded(_ sender: NSMenuItem) {
        PanelSettings.shared.pinExpanded.toggle()
    }

    @objc private func changePosition(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let position = PanelPosition(rawValue: rawValue) else { return }
        PanelSettings.shared.position = position
        panel?.repositionForCurrentSettings()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

}

extension AppDelegate: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        // Update pin checkmark
        if let pinItem = menu.item(withTag: 100) {
            pinItem.state = PanelSettings.shared.pinExpanded ? .on : .off
        }
        // Update position checkmarks in submenu
        if let posItem = menu.item(withTitle: "Position"),
           let posMenu = posItem.submenu {
            let current = PanelSettings.shared.position.rawValue
            for item in posMenu.items {
                item.state = (item.representedObject as? String) == current ? .on : .off
            }
        }
    }
}

extension AppDelegate {
    func setupClickOutsideMonitor() {
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
    let settings = PanelSettings.shared

    @State private var isExpanded = false

    private var shouldExpand: Bool {
        settings.pinExpanded || isExpanded
    }

    private var cornerRadius: CGFloat {
        shouldExpand ? 20 : 18
    }

    var body: some View {
        VStack(spacing: 0) {
            CapsuleView(
                session: sessionManager.activeSession,
                sessionCount: sessionManager.sessions.count,
                activeCount: sessionManager.activeSessionCount
            )

            if shouldExpand {
                ExpandedDetailView(
                    session: sessionManager.activeSession,
                    sessions: sessionManager.sortedSessions,
                    onSelectSession: { id in
                        sessionManager.selectSession(id)
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                .padding(.top, 4)
            }
        }
        .fixedSize()
        .padding(.bottom, shouldExpand ? 4 : 0)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .environment(\.colorScheme, .dark)
        .onHover { hovering in
            if !settings.pinExpanded {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded = hovering
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .ccaniClickOutside)) { _ in
            if !settings.pinExpanded {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    isExpanded = false
                }
            }
        }
    }
}
