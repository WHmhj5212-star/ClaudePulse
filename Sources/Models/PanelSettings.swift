import Foundation
import SwiftUI

enum PanelPosition: String, CaseIterable {
    case topCenter = "top-center"
    case bottomLeft = "bottom-left"
    case bottomRight = "bottom-right"

    var displayName: String {
        switch self {
        case .topCenter: return "Top Center"
        case .bottomLeft: return "Bottom Left"
        case .bottomRight: return "Bottom Right"
        }
    }
}

enum AccentTheme: String, CaseIterable {
    case purple
    case cyan
    case green
    case orange
    case pink

    var displayName: String {
        switch self {
        case .purple: return "Purple"
        case .cyan: return "Cyan"
        case .green: return "Green"
        case .orange: return "Orange"
        case .pink: return "Pink"
        }
    }

    var color: Color {
        switch self {
        case .purple: return Color(red: 0.85, green: 0.5, blue: 1.0)
        case .cyan: return Color(red: 0.3, green: 0.85, blue: 1.0)
        case .green: return Color(red: 0.3, green: 0.95, blue: 0.6)
        case .orange: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .pink: return Color(red: 1.0, green: 0.4, blue: 0.6)
        }
    }
}

@Observable
class PanelSettings {
    static let shared = PanelSettings()

    var position: PanelPosition {
        didSet { UserDefaults.standard.set(position.rawValue, forKey: "panelPosition") }
    }

    var pinExpanded: Bool {
        didSet { UserDefaults.standard.set(pinExpanded, forKey: "pinExpanded") }
    }

    var accentTheme: AccentTheme {
        didSet { UserDefaults.standard.set(accentTheme.rawValue, forKey: "accentTheme") }
    }

    var accentColor: Color { accentTheme.color }

    private init() {
        let posRaw = UserDefaults.standard.string(forKey: "panelPosition") ?? PanelPosition.topCenter.rawValue
        self.position = PanelPosition(rawValue: posRaw) ?? .topCenter
        self.pinExpanded = UserDefaults.standard.bool(forKey: "pinExpanded")
        let themeRaw = UserDefaults.standard.string(forKey: "accentTheme") ?? AccentTheme.purple.rawValue
        self.accentTheme = AccentTheme(rawValue: themeRaw) ?? .purple
    }
}
