import Foundation
import CGdk
import Gdk
import Gtk

public extension StyleContext {

	func getColor(for state: StateFlags) -> Color {
		var raw = GdkRGBA()
		var rgba = RGBA(retaining: &raw)
		self.getColor(state: state, color: rgba)
		return Color(from: rgba)
	}

	func getColor(named name: String) -> Color? {
		var raw = GdkRGBA()
		var rgba = RGBA(retaining: &raw)
		if self.lookupColor(colorName: name, color: rgba) {
			return Color(from: rgba)
		} else {
			return nil
		}
	}

}


