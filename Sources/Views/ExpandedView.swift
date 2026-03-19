import SwiftUI

struct ExpandedDetailView: View {
    let session: Session?
    let sessions: [Session]
    let onSelectSession: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Active session detail
            if let session = session {
                HStack(spacing: 6) {
                    Circle()
                        .fill(stateColor(session.state))
                        .frame(width: 8, height: 8)
                    Text(stateText(session.state))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(stateColor(session.state))
                    if let cwd = session.cwd {
                        Text("·")
                            .foregroundStyle(.white.opacity(0.3))
                        Text(shortPath(cwd))
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))
                            .lineLimit(1)
                            .truncationMode(.head)
                    }
                    Spacer()
                }
            }

            // All sessions list
            if sessions.count > 1 {
                Divider().background(.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Sessions (\(sessions.count))")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .padding(.bottom, 2)

                    ForEach(sessions) { s in
                        SessionRow(session: s, isActive: s.id == session?.id)
                            .onTapGesture { onSelectSession(s.id) }
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 280)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .environment(\.colorScheme, .dark)
    }

    private func stateColor(_ state: SessionState) -> Color {
        switch state {
        case .idle: return .gray
        case .working: return .purple
        case .waitingForUser: return .orange
        case .stale: return .gray.opacity(0.5)
        }
    }

    private func stateText(_ state: SessionState) -> String {
        switch state {
        case .idle: return "Idle"
        case .working: return "Working..."
        case .waitingForUser: return "Waiting for Input"
        case .stale: return "Stale"
        }
    }

    private func shortPath(_ path: String) -> String {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        if path.hasPrefix(home) {
            return "~" + path.dropFirst(home.count)
        }
        return path
    }
}

struct SessionRow: View {
    let session: Session
    let isActive: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(rowStateColor)
                .frame(width: 6, height: 6)
            Text(session.projectName)
                .font(.system(size: 11, weight: isActive ? .semibold : .regular))
                .foregroundStyle(.white.opacity(isActive ? 1.0 : 0.6))
                .lineLimit(1)
            Text(rowStateLabel)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(rowStateColor.opacity(0.8))
            Spacer()
            if session.isActive {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(session.formattedTime)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(isActive ? .white.opacity(0.08) : .clear, in: RoundedRectangle(cornerRadius: 6))
    }

    private var rowStateColor: Color {
        switch session.state {
        case .idle: return isActive ? .white : .gray
        case .working: return .purple
        case .waitingForUser: return .orange
        case .stale: return .gray.opacity(0.5)
        }
    }

    private var rowStateLabel: String {
        switch session.state {
        case .idle: return ""
        case .working: return "working"
        case .waitingForUser: return "waiting"
        case .stale: return "stale"
        }
    }
}
