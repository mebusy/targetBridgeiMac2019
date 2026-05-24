import AppKit
import Foundation

@MainActor
final class TBInputRelayController {
    typealias Handler = (TBMonitorInputEvent) -> Void

    private var localMonitors: [Any] = []
    private var globalMonitors: [Any] = []
    private var handler: Handler?

    func start(handler: @escaping Handler) {
        stop()
        self.handler = handler

        installKeyboardMonitors()
        installMouseMonitors()
        installScrollMonitors()
    }

    func stop() {
        for token in localMonitors {
            NSEvent.removeMonitor(token)
        }
        for token in globalMonitors {
            NSEvent.removeMonitor(token)
        }
        localMonitors.removeAll()
        globalMonitors.removeAll()
        handler = nil
    }

    private func installKeyboardMonitors() {
        let mask: NSEvent.EventTypeMask = [.keyDown, .keyUp, .flagsChanged]

        let global = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }
        if let global { globalMonitors.append(global) }

        let local = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
        if let local { localMonitors.append(local) }
    }

    private func installMouseMonitors() {
        let mask: NSEvent.EventTypeMask = [
            .mouseMoved,
            .leftMouseDragged,
            .rightMouseDragged,
            .otherMouseDragged,
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .otherMouseDown,
            .otherMouseUp
        ]

        let global = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }
        if let global { globalMonitors.append(global) }

        let local = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
        if let local { localMonitors.append(local) }
    }

    private func installScrollMonitors() {
        let mask: NSEvent.EventTypeMask = [.scrollWheel]

        let global = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }
        if let global { globalMonitors.append(global) }

        let local = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
        if let local { localMonitors.append(local) }
    }

    private func handle(_ event: NSEvent) {
        guard let handler, let relayEvent = convert(event) else { return }
        handler(relayEvent)
    }

    private func convert(_ event: NSEvent) -> TBMonitorInputEvent? {
        switch event.type {
        case .mouseMoved, .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
            return TBMonitorInputEvent(
                kind: "move",
                dx: Int(event.deltaX.rounded()),
                dy: Int(event.deltaY.rounded()),
                scrollX: nil,
                scrollY: nil,
                keyCode: nil
            )
        case .leftMouseDown:
            return TBMonitorInputEvent(kind: "leftDown", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .leftMouseUp:
            return TBMonitorInputEvent(kind: "leftUp", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .rightMouseDown:
            return TBMonitorInputEvent(kind: "rightDown", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .rightMouseUp:
            return TBMonitorInputEvent(kind: "rightUp", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .otherMouseDown:
            return TBMonitorInputEvent(kind: "otherDown", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .otherMouseUp:
            return TBMonitorInputEvent(kind: "otherUp", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: nil)
        case .scrollWheel:
            return TBMonitorInputEvent(
                kind: "scroll",
                dx: nil,
                dy: nil,
                scrollX: Int(event.scrollingDeltaX.rounded()),
                scrollY: Int(event.scrollingDeltaY.rounded()),
                keyCode: nil
            )
        case .keyDown:
            return TBMonitorInputEvent(kind: "keyDown", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: event.keyCode)
        case .keyUp:
            return TBMonitorInputEvent(kind: "keyUp", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: event.keyCode)
        case .flagsChanged:
            let down = modifierIsDown(for: event)
            return TBMonitorInputEvent(kind: down ? "keyDown" : "keyUp", dx: nil, dy: nil, scrollX: nil, scrollY: nil, keyCode: event.keyCode)
        default:
            return nil
        }
    }

    private func modifierIsDown(for event: NSEvent) -> Bool {
        switch Int(event.keyCode) {
        case 54, 55:
            return event.modifierFlags.contains(.command)
        case 56, 60:
            return event.modifierFlags.contains(.shift)
        case 58, 61:
            return event.modifierFlags.contains(.option)
        case 59, 62:
            return event.modifierFlags.contains(.control)
        case 57:
            return event.modifierFlags.contains(.capsLock)
        case 63:
            return event.modifierFlags.contains(.function)
        default:
            return false
        }
    }
}
