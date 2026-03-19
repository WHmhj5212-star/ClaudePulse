import SwiftUI
import AppKit

class SizeTrackingHostingView<Content: View>: NSHostingView<Content> {
    var onSizeChange: ((CGSize) -> Void)?
    private var lastReportedSize: CGSize = .zero

    override func layout() {
        super.layout()
        let fitting = fittingSize
        if fitting != lastReportedSize {
            lastReportedSize = fitting
            onSizeChange?(fitting)
        }
    }
}
