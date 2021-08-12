import Foundation
import CGtk
import Gtk

public extension IconThemeProtocol {

	static func registerIcons(in bundle: Bundle) {
		guard let resourceURL = bundle.resourceURL else {
			return
		}
		let path = resourceURL.appendingPathComponent("icons").path
		gtk_icon_theme_append_search_path(gtk_icon_theme_get_default(), path)
	}

}

