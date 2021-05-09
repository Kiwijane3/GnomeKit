import Foundation
import Gtk

public func isDarkTheme() -> Bool {
	let settings = Settings.getDefault()
	let themeName = settings?.get(property: .gtkThemeName)
	if themeName?.ptr == nil {
		return false
	}
	return themeName?.getString().contains("dark") ?? false
}
