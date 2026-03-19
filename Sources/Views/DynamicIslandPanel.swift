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
        repositionForCurrentSettings()
    }

    func repositionForCurrentSettings() {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let margin: CGFloat = 12

        let origin: NSPoint
        switch PanelSettings.shared.position {
        case .topCenter:
            origin = NSPoint(
                x: screenFrame.midX - frame.width / 2,
                y: screenFrame.maxY - frame.height - 8
            )
        case .bottomLeft:
            origin = NSPoint(
                x: screenFrame.minX + margin,
                y: screenFrame.minY + margin
            )
        case .bottomRight:
            origin = NSPoint(
                x: screenFrame.maxX - frame.width - margin,
                y: screenFrame.minY + margin
            )
        }
        setFrameOrigin(origin)
    }

    func updateFrameForContentSize(_ contentSize: CGSize) {
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let margin: CGFloat = 12
        let newWidth = max(contentSize.width, 280)
        let newHeight = contentSize.height

        let newOrigin: NSPoint
        switch PanelSettings.shared.position {
        case .topCenter:
            let topY = frame.origin.y + frame.size.height
            newOrigin = NSPoint(
                x: screenFrame.midX - newWidth / 2,
                y: topY - newHeight
            )
        case .bottomLeft:
            newOrigin = NSPoint(
                x: screenFrame.minX + margin,
                y: screenFrame.minY + margin
            )
        case .bottomRight:
            newOrigin = NSPoint(
                x: screenFrame.maxX - newWidth - margin,
                y: screenFrame.minY + margin
            )
        }

        let newFrame = NSRect(origin: newOrigin, size: CGSize(width: newWidth, height: newHeight))
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(newFrame, display: true)
        }
    }
}
