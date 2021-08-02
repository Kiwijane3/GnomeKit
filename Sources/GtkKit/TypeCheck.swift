import Foundation
import GLibObject
import Gtk
import CGtk

public extension ObjectProtocol {

	/**
		Returns whether the GType of the underlying instance is `GtkWidget`
	*/
	func isAWidget() -> Bool {
		return typeIsA(type: type, isAType: gtk_widget_get_type())
	}

	/**
		Returns whether the GType of the underlying instance is `GtkContainer`
	*/
	func isAContainer() -> Bool {
		return typeIsA(type: type, isAType: gtk_container_get_type())
	}

	/**
		Returns whether the GType of the underlying instance is `GtkBin`
	*/
	func isABin() -> Bool {
		return typeIsA(type: type, isAType: gtk_bin_get_type())
	}

}
