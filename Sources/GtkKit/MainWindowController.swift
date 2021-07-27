import Foundation
import Gtk

public class MainWindowController: WindowController {

	public var application: Application;

	public init(application: Application) {
		self.application = application
		super.init()

	}

	open override func generateContainer() {
		let window = MainWindow(application: application)
		window.setDefaultSize(width: 1366, height: 768)
		container = window
		window.presentationController = self
		window.onUnrealize() { [weak self] (_) in
			self?.containerDidUnrealise()
		}
	}

	open override func showHeaderbar() {
		super.showHeaderbar()
		headerbarStack?.showsWindowControls = true
	}

}

// Main Window needs to be in a
public class MainWindow: ApplicationWindow {

	public var presentationController: MainWindowController?

	public override init<T: ApplicationProtocol>(application: T) {
		super.init(application: application)
		becomeSwiftObj()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
		becomeSwiftObj()
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
		becomeSwiftObj()
	}

}
