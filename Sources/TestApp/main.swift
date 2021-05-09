import Foundation
import Gtk
import GtkKit

Application.run(startupHandler: nil) { (app) in
	let windowController = WindowController(application: Application(app))
	windowController.show(NavigationController(withRoot: CollectionTestController()))
}
