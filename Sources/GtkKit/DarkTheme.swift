import Foundation
import Gtk

public func isDarkTheme() -> Bool {
	let settings = Settings.getDefault()
	let themeName = settings?.get(property: .gtkThemeName).getString()
	return themeName?.contains("dark") ?? false
}
