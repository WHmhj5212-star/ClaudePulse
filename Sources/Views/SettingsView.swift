import SwiftUI
import AppKit

struct SettingsView: View {
    let settings = PanelSettings.shared
    var updateChecker: UpdateChecker?
    var onClose: (() -> Void)?

    @State private var positionHover: PanelPosition?
    @State private var toggleHovered = false
    @State private var checkUpdateHovered = false
    @State private var downloadHovered = false
    @State private var quitHovered = false

    private let accentPurple = Color(red: 0.7, green: 0.4, blue: 1.0)

    var body: some View {
        VStack(spacing: 0) {
            // Custom title bar
            HStack {
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button {
                    onClose?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.4))
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)

            // Divider
            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 0.5)
                .padding(.horizontal, 12)

            VStack(spacing: 16) {
                // Position selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Position")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))

                    HStack(spacing: 4) {
                        ForEach(PanelPosition.allCases, id: \.self) { pos in
                            let isSelected = settings.position == pos
                            let isHovered = positionHover == pos

                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    settings.position = pos
                                }
                                NotificationCenter.default.post(name: .ccaniRepositionPanel, object: nil)
                            } label: {
                                Text(pos.displayName)
                                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                                    .foregroundStyle(isSelected ? .white : .white.opacity(isHovered ? 0.7 : 0.45))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(isSelected ? .white.opacity(0.12) : .white.opacity(isHovered ? 0.08 : 0.05))
                                    )
                            }
                            .buttonStyle(.plain)
                            .onHover { h in
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    positionHover = h ? pos : nil
                                }
                            }
                        }
                    }
                }

                // Keep Expanded toggle
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Keep Expanded")
                            .font(.system(size: 12))
                            .foregroundStyle(.white)
                        Text("Panel stays open without hovering")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.35))
                    }

                    Spacer()

                    // Custom toggle button
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            settings.pinExpanded.toggle()
                        }
                    } label: {
                        ZStack {
                            Capsule()
                                .fill(settings.pinExpanded ? accentPurple : .white.opacity(0.15))
                                .frame(width: 34, height: 20)

                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                                .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                                .offset(x: settings.pinExpanded ? 7 : -7)
                        }
                    }
                    .buttonStyle(.plain)
                    .onHover { h in
                        toggleHovered = h
                    }
                }

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                // Updates section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Updates")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))

                    HStack {
                        if let checker = updateChecker, checker.updateAvailable,
                           let version = checker.latestVersion {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                            Text("v\(version) available")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                checker.openDownloadPage()
                            } label: {
                                Text("Download")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(downloadHovered ? .white : .white.opacity(0.7))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.opacity(downloadHovered ? 0.15 : 0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                            .onHover { h in
                                withAnimation(.easeInOut(duration: 0.1)) { downloadHovered = h }
                            }
                        } else {
                            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
                            Text("v\(currentVersion)")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.45))
                            Spacer()
                            Button {
                                updateChecker?.checkForUpdates()
                            } label: {
                                Text("Check Now")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(checkUpdateHovered ? .white : .white.opacity(0.7))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(.white.opacity(checkUpdateHovered ? 0.15 : 0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                            .onHover { h in
                                withAnimation(.easeInOut(duration: 0.1)) { checkUpdateHovered = h }
                            }
                        }
                    }
                }

                // Divider
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)

                // Quit button
                HStack {
                    Spacer()
                    Button {
                        NSApp.terminate(nil)
                    } label: {
                        Text("Quit Pulse")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(quitHovered ? Color.red : Color.red.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .onHover { h in
                        withAnimation(.easeInOut(duration: 0.1)) { quitHovered = h }
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 280)
        .fixedSize()
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .environment(\.colorScheme, .dark)
    }
}

class SettingsWindowController {
    private var panel: NSPanel?

    func showSettings(updateChecker: UpdateChecker) {
        if let existing = panel, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 300),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false

        let settingsView = SettingsView(
            updateChecker: updateChecker,
            onClose: { [weak panel] in
                panel?.orderOut(nil)
            }
        )
        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.sizingOptions = [.intrinsicContentSize]
        panel.contentView = hostingView

        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        self.panel = panel
    }
}
