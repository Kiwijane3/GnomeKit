import Foundation
import Gtk

public func isDarkTheme() -> Bool {
	let settings = Settings.getDefault()
	debugPrint(settings?.ptr)
	if settings?.ptr == nil {
		return false
	}
	let themeName = settings?.get(property: .gtkThemeName)
	debugPrint(themeName?.ptr)
	if themeName?.ptr == nil {
		return false
	}
	return themeName?.getString().contains("dark") ?? false
}
