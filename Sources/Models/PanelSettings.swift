import Foundation

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

@Observable
class PanelSettings {
    static let shared = PanelSettings()

    var position: PanelPosition {
        didSet { UserDefaults.standard.set(position.rawValue, forKey: "panelPosition") }
    }

    var pinExpanded: Bool {
        didSet { UserDefaults.standard.set(pinExpanded, forKey: "pinExpanded") }
    }

    private init() {
        let posRaw = UserDefaults.standard.string(forKey: "panelPosition") ?? PanelPosition.topCenter.rawValue
        self.position = PanelPosition(rawValue: posRaw) ?? .topCenter
        self.pinExpanded = UserDefaults.standard.bool(forKey: "pinExpanded")
    }
}
