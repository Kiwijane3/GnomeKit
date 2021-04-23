import Foundation
import GLibObject
import Gtk
import CGtk

public extension ObjectProtocol {

	func isAWidget() -> Bool {
		return typeIsA(type: type, isAType: gtk_widget_get_type())
	}

	func isAContainer() -> Bool {
		return typeIsA(type: type, isAType: gtk_container_get_type())
	}

	func isABin() -> Bool {
		return typeIsA(type: type, isAType: gtk_bin_get_type())
	}

}
