import Foundation
import Gtk
import GtkKit

Application.run(startupHandler: nil) { (app) in
	let windowController = MainWindowController(application: Application(app))
	windowController.install(controller: MenuButtonTestController())
	windowController.beginPresentation()
	print("Presented root")
}
