import Foundation
import Gdk
import Gtk

public class ModalWindowController: WindowController {

	/**
		The window of the most recent `WindowController` ancestor.
	*/
	public var parentWindow: Gtk.Window? {
		return ancestor(ofType: WindowController.self)?.window
 	}

 	var closeController: EventControllerKey?

	/**
		The preferred size of the presented window.
	*/
	public var preferredSize: CGSize {
		guard let parentWindow = parentWindow else {
			return CGSize(width: 480, height: 800)
		}
		return CGSize(width: Double(parentWindow.allocatedWidth) * 0.4, height: Double(parentWindow.allocatedHeight) * 0.8)
	}

	public override func generateContainer() {
		let window = Window(type: .toplevel)
		window.modal = true
		window.setKeepAbove(setting: true)
		window.resizable = false
		if let parentWindow = ancestor(ofType: WindowController.self)?.window {
			window.setTransientFor(parent: parentWindow)
			window.set(position: .centerOnParent)
			window.setDefaultSize(width: Int(preferredSize.width), height: Int(preferredSize.height))
		}
		container = window

		closeController = EventControllerKey(widget: self.window)
		closeController?.onKeyReleased(handler: onKeyReleased)

		window.onUnrealize() { [weak self] (_) in
			self?.containerDidUnrealise()
		}
	}

	public func onKeyReleased(_ controller: EventControllerKeyRef, keyval: UInt, keycode: UInt, state: Gdk.ModifierType) {
		if keyval == Gdk.KEY_Escape {
			endPresentation()
		}
	}

}
