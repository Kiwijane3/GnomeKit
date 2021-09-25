import Foundation
import CGdk
import CGtk
import Gtk

public extension Popover {

	func set(pointingTo point: CGPoint) {
		var rect = GdkRectangle()
		rect.x = Int32(point.x)
		rect.y = Int32(point.y)
		rect.width = 0
		rect.height = 0
		gtk_popover_set_pointing_to(self.popover_ptr, &rect)
	}

	func set(pointingTo cgRect: CGRect) {
		var rect = GdkRectangle()
		rect.x = Int32(cgRect.origin.x)
		rect.y = Int32(cgRect.origin.y)
		rect.width = Int32(cgRect.size.width)
		rect.height = Int32(cgRect.size.height)
		gtk_popover_set_pointing_to(self.popover_ptr, &rect)
	}

}
