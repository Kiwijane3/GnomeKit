import Foundation
import Gdk
import CGdk
import Gtk
import GtkKit

Application.run(startupHandler: nil) { (app) in
	let windowController = MainWindowController(application: Application(app))
	windowController.install(controller: DocumentPickerTestController())
	windowController.beginPresentation()
	print("Presented root")
	IconTheme.getDefault().appendSearch(bundle: Bundle.module)
}
