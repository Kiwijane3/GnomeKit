import Foundation
import Gtk
import Gdk
import CGdk

public extension WidgetProtocol {

	func child<T: Widget>(named name: String) -> T! {
		return child(named: name, of: T.self)
	}

	func child<T: Widget>(named name: String, of type: T.Type) -> T! {
		debugPrint("Called child on \(self.name)")
		if self.name == name {
			return T(retainingRaw: ptr)
		}
		if isABin() {
			let binRef = BinRef(raw: ptr)
			if let contained = binRef.child {
				return contained.child(named: name, of: type)
			}
		}
		if isAContainer() {
			let containerRef = ContainerRef(raw: ptr)
			// Children returns a nil pointer if there are no children.
			if let children = containerRef.children {
				for ptr in children {
					if let result = WidgetRef(raw: ptr).child(named: name, of: type) {
						return result
					}
				}
			}
		}
		return nil
	}

	/// Returns whether the current theme is dark, based on analysing the text color and the background color.
	func isDarkTheme() -> Bool {
		// We do this by comparing the foreground and background colors.
		// Light themes use dark foregrounds on light backgrounds, so the average luminence of the background should be greater than the foreground's
		// Vice versa for dark themes.
		let styleContext = getStyleContext()!
		var gForeground = GdkRGBA.init()
		var foreground = RGBARef(raw: &gForeground)
		styleContext.getColor(state: .normal, color: foreground)
		var gBackground = GdkRGBA.init()
		var background = RGBARef(raw: &gBackground)
		styleContext.getBackgroundColor(state: .normal, color: background)
		var averageLuminance = { (rgba: RGBAProtocol) -> Double in
			return (rgba.red + rgba.green + rgba.blue) / 3
		}
		return averageLuminance(foreground) > averageLuminance(background)
	}

}
