import Foundation
import CGtk
import Gtk

public extension IconThemeProtocol {

	func appendSearch(bundle: Bundle) {
		guard let resourceURL = bundle.resourceURL else {
			return
		}
		let path = resourceURL.appendingPathComponent("icons").absoluteString
		print("Adding \(path) to icon search path" )
		gtk_icon_theme_add_resource_path(self.icon_theme_ptr, path)
		print("Test icon loaded: \(gtk_icon_theme_has_icon(gtk_icon_theme_get_default(), "penguin-symbolic"))")
		print(resourceURL.absoluteString)
	}

}

