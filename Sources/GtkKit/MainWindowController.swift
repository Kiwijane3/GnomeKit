import Foundation
import Gtk

public class MainWindowController: WindowController {

	public var application: Application;

	public init(application: Application) {
		self.application = application
		super.init()

	}

	open override func generateContainer() {
		let window = ApplicationWindow(application: application)
		window.setDefaultSize(width: 1366, height: 768)
		container = window
	}

	open override func showHeaderbar() {
		super.showHeaderbar()
		headerbarStack?.showsWindowControls = true
	}

}
