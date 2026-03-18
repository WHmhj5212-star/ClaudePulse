import SwiftUI

struct CapsuleView: View {
    let session: Session?
    let sessionCount: Int

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .modifier(PulseAnimation(state: session?.state ?? .idle))

            Text(statusText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white)

            Spacer()

            if session != nil {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(session?.formattedTime ?? "00:00")
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            if sessionCount > 1 {
                HStack(spacing: 3) {
                    ForEach(0..<min(sessionCount - 1, 3), id: \.self) { _ in
                        Circle()
                            .fill(.white.opacity(0.4))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .frame(width: 200, height: 36)
        .background(.ultraThinMaterial, in: Capsule())
        .environment(\.colorScheme, .dark)
    }

    private var statusColor: Color {
        switch session?.state ?? .idle {
        case .idle: return .gray
        case .thinking: return .purple
        case .toolExecuting: return .blue
        case .waitingForUser: return .orange
        case .stale: return .gray.opacity(0.5)
        }
    }

    private var statusText: String {
        switch session?.state ?? .idle {
        case .idle: return "Idle"
        case .thinking: return "Thinking..."
        case .toolExecuting: return "Executing..."
        case .waitingForUser: return "Waiting"
        case .stale: return "Stale"
        }
    }
}

struct PulseAnimation: ViewModifier {
    let state: SessionState

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .opacity(pulseOpacity)
            .scaleEffect(pulseScale)
            .onAppear { phase = 1 }
            .onChange(of: state) { _, _ in phase = 0; phase = 1 }
            .animation(animation, value: phase)
    }

    private var pulseOpacity: Double {
        switch state {
        case .thinking: return phase == 1 ? 0.4 : 1.0
        case .toolExecuting: return phase == 1 ? 0.5 : 1.0
        case .waitingForUser: return phase == 1 ? 0.3 : 1.0
        default: return 1.0
        }
    }

    private var pulseScale: CGFloat {
        switch state {
        case .toolExecuting: return phase == 1 ? 1.3 : 1.0
        default: return 1.0
        }
    }

    private var animation: Animation? {
        switch state {
        case .thinking: return .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        case .toolExecuting: return .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        case .waitingForUser: return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        default: return nil
        }
    }
}
