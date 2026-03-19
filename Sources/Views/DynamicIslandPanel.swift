import SwiftUI
import AppKit

class DynamicIslandPanel: NSPanel {
    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 36),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        self.contentView = contentView
        positionAtTopCenter()
    }

    func positionAtTopCenter() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.maxY - frame.height - 8
        setFrameOrigin(NSPoint(x: x, y: y))
    }

    func updateFrameForContentSize(_ contentSize: CGSize) {
        guard let screen = NSScreen.main else { return }
        let topY = frame.origin.y + frame.size.height
        let newWidth = max(contentSize.width, 200)
        let newHeight = contentSize.height
        let x = screen.visibleFrame.midX - newWidth / 2
        let y = topY - newHeight
        let newFrame = NSRect(x: x, y: y, width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)
    }
}
