import Foundation
import AppKit

@Observable
class UpdateChecker {
    var updateAvailable = false
    var latestVersion: String?
    var downloadURL: String?

    private let currentVersion: String
    private var timer: Timer?

    // GitHub releases API endpoint — set via SUFeedURL in Info.plist
    // Example: https://api.github.com/repos/owner/repo/releases/latest
    private let feedURL: String?

    init() {
        currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        feedURL = Bundle.main.infoDictionary?["SUFeedURL"] as? String
    }

    func startPeriodicCheck() {
        checkForUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: 6 * 3600, repeats: true) { [weak self] _ in
            self?.checkForUpdates()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func checkForUpdates() {
        guard let feedURL, let url = URL(string: feedURL) else { return }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let tagName = json["tag_name"] as? String else { return }

                let cleanVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

                // Find DMG download URL from assets
                let dmgURL: String? = {
                    guard let assets = json["assets"] as? [[String: Any]] else { return nil }
                    for asset in assets {
                        if let name = asset["name"] as? String, name.hasSuffix(".dmg"),
                           let url = asset["browser_download_url"] as? String {
                            return url
                        }
                    }
                    return nil
                }()

                // Fallback to html_url (release page) if no DMG asset
                let fallbackURL = json["html_url"] as? String
                let resolvedURL = dmgURL ?? fallbackURL

                await MainActor.run {
                    if self.isNewer(cleanVersion, than: self.currentVersion) {
                        self.updateAvailable = true
                        self.latestVersion = cleanVersion
                        self.downloadURL = resolvedURL
                    }
                }
            } catch {
                print("[Pulse] Update check failed: \(error)")
            }
        }
    }

    func openDownloadPage() {
        guard let downloadURL, let url = URL(string: downloadURL) else { return }
        NSWorkspace.shared.open(url)
    }

    private func isNewer(_ new: String, than current: String) -> Bool {
        let newParts = new.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(newParts.count, currentParts.count) {
            let n = i < newParts.count ? newParts[i] : 0
            let c = i < currentParts.count ? currentParts[i] : 0
            if n > c { return true }
            if n < c { return false }
        }
        return false
    }
}
