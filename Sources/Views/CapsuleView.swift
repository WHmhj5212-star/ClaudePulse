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
    let activeCount: Int

    var body: some View {
        HStack(spacing: 8) {
            // Claude logo icon with status color and animation
            claudeIconView
                .frame(width: 16, height: 16)

            if let session = session {
                Text(session.projectName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text(statusText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            } else {
                Text("Claude Code")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            if let session = session, session.isActive {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(session.formattedTime)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            if sessionCount > 1 {
                HStack(spacing: 2) {
                    if activeCount > 0 {
                        Text("\(activeCount)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.7, green: 0.4, blue: 1.0))
                    }
                    if activeCount > 0 && activeCount < sessionCount {
                        Text("/")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    Text("\(sessionCount)")
                        .font(.system(size: 10, weight: activeCount > 0 ? .medium : .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(activeCount > 0 ? 0.5 : 0.8))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.white.opacity(0.1), in: Capsule())
            }
        }
        .padding(.horizontal, 14)
        .frame(width: 280, height: 36)
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
        case .working: return Color(red: 0.7, green: 0.4, blue: 1.0)
        case .waitingForUser: return .orange
        case .stale: return .gray.opacity(0.5)
        }
    }

    private var statusText: String {
        switch session?.state ?? .idle {
        case .idle: return "Idle"
        case .working: return "Working..."
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
        case .working: return isAnimating ? 0.5 : 1.0
        case .waitingForUser: return isAnimating ? 0.3 : 1.0
        default: return 1.0
        }
    }

    private var scale: CGFloat {
        switch state {
        case .working: return isAnimating ? 1.15 : 0.85
        default: return 1.0
        }
    }

    private var rotation: Angle {
        switch state {
        case .working: return isAnimating ? .degrees(360) : .degrees(0)
        default: return .degrees(0)
        }
    }

    private var animation: Animation? {
        switch state {
        case .working:
            return .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        case .waitingForUser:
            return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        default:
            return nil
        }
    }
}
