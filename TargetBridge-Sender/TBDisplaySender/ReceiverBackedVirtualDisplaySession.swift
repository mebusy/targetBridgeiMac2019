import CoreGraphics
import Foundation

extension CGVirtualDisplayDescriptor: @unchecked @retroactive Sendable {}
extension CGVirtualDisplay: @unchecked @retroactive Sendable {}
extension CGVirtualDisplaySettings: @unchecked @retroactive Sendable {}

@MainActor
final class ReceiverBackedVirtualDisplaySession {
    private var virtualDisplay: CGVirtualDisplay?
    private(set) var displayID: CGDirectDisplayID = kCGNullDirectDisplay
    private(set) var displayName: String = ""
    private let displayQueue = DispatchQueue(label: "fd.tbmonitor.sender.virtual-display", qos: .userInitiated)

    func create(from profile: TBMonitorDisplayProfile, refreshRate: Double? = nil) -> Bool {
        destroy()
        let preferredRefreshRate = refreshRate ?? profile.refreshRate

        let descriptor = CGVirtualDisplayDescriptor()
        descriptor.queue = displayQueue
        descriptor.name = "TB Monitor - \(profile.receiverName)"
        descriptor.vendorID = 0xEEEE
        descriptor.productID = 0x5000
        descriptor.serialNum = 0x2026
        descriptor.maxPixelsWide = UInt32(profile.panelWidth)
        descriptor.maxPixelsHigh = UInt32(profile.panelHeight)

        let ppi = 218.0
        descriptor.sizeInMillimeters = CGSize(
            width: Double(profile.panelWidth) / ppi * 25.4,
            height: Double(profile.panelHeight) / ppi * 25.4
        )

        guard let display = CGVirtualDisplay(descriptor: descriptor) else {
            return false
        }

        let settings = CGVirtualDisplaySettings()
        settings.hiDPI = profile.hiDPI
        guard let mode = CGVirtualDisplayMode(
            width: UInt(profile.modeWidth),
            height: UInt(profile.modeHeight),
            refreshRate: preferredRefreshRate
        ) else {
            return false
        }
        settings.modes = [mode]

        guard display.apply(settings), display.displayID != kCGNullDirectDisplay else {
            return false
        }

        activatePreferredMode(for: display.displayID, profile: profile, refreshRate: preferredRefreshRate)

        virtualDisplay = display
        displayID = display.displayID
        displayName = profile.receiverName
        return true
    }

    func destroy() {
        virtualDisplay = nil
        displayID = kCGNullDirectDisplay
        displayName = ""
    }

    @discardableResult
    private func activatePreferredMode(for displayID: CGDirectDisplayID, profile: TBMonitorDisplayProfile, refreshRate: Double) -> Bool {
        let timeout = Date().addingTimeInterval(2.0)
        while Date() < timeout {
            if let preferredMode = preferredMode(for: displayID, profile: profile, refreshRate: refreshRate) {
                return CGDisplaySetDisplayMode(displayID, preferredMode, nil) == .success
            }
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }
        return false
    }

    private func preferredMode(for displayID: CGDirectDisplayID, profile: TBMonitorDisplayProfile, refreshRate: Double) -> CGDisplayMode? {
        guard let modes = CGDisplayCopyAllDisplayModes(displayID, nil) as? [CGDisplayMode] else {
            return nil
        }

        let exactMatch = modes.first { mode in
            mode.width == profile.modeWidth
                && mode.height == profile.modeHeight
                && abs(mode.refreshRate - refreshRate) < 0.5
        }
        if let exactMatch {
            return exactMatch
        }

        return modes.first { mode in
            mode.width == profile.modeWidth
                && mode.height == profile.modeHeight
        }
    }
}
