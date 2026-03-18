import SwiftUI

// Claude AI logo path (from Bootstrap Icons)
struct ClaudeIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width / 16
        let h = rect.height / 16

        // Scaled version of the Bootstrap Icons Claude path
        path.move(to: CGPoint(x: 3.127 * w, y: 10.604 * h))
        path.addLine(to: CGPoint(x: 6.262 * w, y: 8.844 * h))
        path.addLine(to: CGPoint(x: 6.315 * w, y: 8.691 * h))
        path.addLine(to: CGPoint(x: 6.262 * w, y: 8.606 * h))
        path.addLine(to: CGPoint(x: 6.11 * w, y: 8.606 * h))
        path.addLine(to: CGPoint(x: 5.585 * w, y: 8.574 * h))
        path.addLine(to: CGPoint(x: 3.794 * w, y: 8.526 * h))
        path.addLine(to: CGPoint(x: 2.24 * w, y: 8.461 * h))
        path.addLine(to: CGPoint(x: 0.735 * w, y: 8.381 * h))
        path.addLine(to: CGPoint(x: 0.355 * w, y: 8.3 * h))
        path.addLine(to: CGPoint(x: 0 * w, y: 7.832 * h))
        path.addLine(to: CGPoint(x: 0.036 * w, y: 7.598 * h))
        path.addLine(to: CGPoint(x: 0.356 * w, y: 7.384 * h))
        path.addLine(to: CGPoint(x: 0.811 * w, y: 7.424 * h))
        path.addLine(to: CGPoint(x: 1.82 * w, y: 7.493 * h))
        path.addLine(to: CGPoint(x: 3.333 * w, y: 7.598 * h))
        path.addLine(to: CGPoint(x: 4.43 * w, y: 7.662 * h))
        path.addLine(to: CGPoint(x: 6.056 * w, y: 7.832 * h))
        path.addLine(to: CGPoint(x: 6.315 * w, y: 7.832 * h))
        path.addLine(to: CGPoint(x: 6.351 * w, y: 7.727 * h))
        path.addLine(to: CGPoint(x: 6.262 * w, y: 7.662 * h))
        path.addLine(to: CGPoint(x: 6.194 * w, y: 7.598 * h))

        return path
    }
}

struct CapsuleView: View {
    let session: Session?
    let sessionCount: Int

    var body: some View {
        HStack(spacing: 8) {
            // Claude logo icon with status color and animation
            claudeIconView
                .frame(width: 16, height: 16)

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

    @ViewBuilder
    private var claudeIconView: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(statusColor)
            .modifier(IconAnimation(state: session?.state ?? .idle))
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

struct IconAnimation: ViewModifier {
    let state: SessionState

    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .onAppear { isAnimating = true }
            .onChange(of: state) { _, _ in
                isAnimating = false
                withAnimation { isAnimating = true }
            }
            .animation(animation, value: isAnimating)
    }

    private var opacity: Double {
        switch state {
        case .thinking: return isAnimating ? 0.5 : 1.0
        case .waitingForUser: return isAnimating ? 0.3 : 1.0
        default: return 1.0
        }
    }

    private var scale: CGFloat {
        switch state {
        case .thinking: return isAnimating ? 1.15 : 0.85
        case .toolExecuting: return isAnimating ? 1.2 : 0.9
        default: return 1.0
        }
    }

    private var rotation: Angle {
        switch state {
        case .thinking: return isAnimating ? .degrees(180) : .degrees(0)
        case .toolExecuting: return isAnimating ? .degrees(360) : .degrees(0)
        default: return .degrees(0)
        }
    }

    private var animation: Animation? {
        switch state {
        case .thinking:
            return .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        case .toolExecuting:
            return .linear(duration: 1.5).repeatForever(autoreverses: false)
        case .waitingForUser:
            return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        default:
            return nil
        }
    }
}
