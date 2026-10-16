import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var latestLeftMouseDownEvent: NSEvent?

  override func sendEvent(_ event: NSEvent) {
    if event.type == .leftMouseDown {
      latestLeftMouseDownEvent = event
    }
    super.sendEvent(event)
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = .clear
    contentViewController = flutterViewController

    let windowChannel = FlutterMethodChannel(
      name: "pet_agent/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    windowChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "window_unavailable", message: "桌宠窗口不可用。", details: nil))
        return
      }

      switch call.method {
      case "startDragging":
        beginDragging()
        result(nil)
      case "showPetMenu":
        showPetMenu()
        result(nil)
      case "resizeFromHandle":
        let arguments = call.arguments as? [String: Any]
        let deltaX = arguments?["deltaX"] as? Double ?? 0
        resizeFromHandle(deltaX: CGFloat(deltaX))
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    setContentSize(NSSize(width: 300, height: 360))
    minSize = NSSize(width: 150, height: 180)
    maxSize = NSSize(width: 420, height: 500)
    styleMask = [.borderless]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    isMovableByWindowBackground = true
    backgroundColor = .clear
    isOpaque = false
    hasShadow = false
    level = .floating
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  private func beginDragging() {
    guard let event = latestLeftMouseDownEvent ?? NSApp.currentEvent else {
      return
    }
    performDrag(with: event)
  }

  private func resizeFromHandle(deltaX: CGFloat) {
    let currentSize = contentView?.bounds.size ?? frame.size
    let newWidth = min(max(currentSize.width + deltaX, minSize.width), maxSize.width)
    let newHeight = min(max(newWidth * 1.2, minSize.height), maxSize.height)
    setContentSize(NSSize(width: newWidth, height: newHeight))
  }

  private func showPetMenu() {
    let menu = NSMenu()
    menu.addItem(
      withTitle: "缩小",
      action: #selector(miniaturize(_:)),
      keyEquivalent: ""
    )
    menu.addItem(.separator())
    menu.addItem(
      withTitle: "退出桌宠",
      action: #selector(NSApplication.terminate(_:)),
      keyEquivalent: "q"
    )
    menu.popUp(positioning: nil, at: .zero, in: contentView)
  }
}
