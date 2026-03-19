import Foundation

@Observable
class Session: Identifiable {
    let id: String  // session_id from Claude Code
    let startTime: Date
    var state: SessionState = .idle
    var lastEventTime: Date
    var cwd: String?

    init(id: String, cwd: String? = nil) {
        self.id = id
        self.startTime = Date()
        self.lastEventTime = Date()
        self.cwd = cwd
    }

    func handleEvent(_ event: HookEvent) {
        lastEventTime = Date()

        switch event.hookEventName {
        case "SessionStart":
            state = .idle
            if let cwd = event.cwd { self.cwd = cwd }
        case "UserPromptSubmit", "PreToolUse", "PostToolUse", "PostToolUseFailure":
            state = .working
        case "PermissionRequest":
            state = .waitingForUser
        case "Stop":
            state = .idle
        default:
            break
        }
    }

    var projectName: String {
        if let cwd = cwd {
            return (cwd as NSString).lastPathComponent
        }
        return String(id.prefix(8))
    }

    var isActive: Bool {
        switch state {
        case .working, .waitingForUser:
            return true
        default:
            return false
        }
    }

    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    var formattedTime: String {
        let total = Int(elapsedTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
