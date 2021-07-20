import Foundation
import Gtk

// The presentation handles presenting a view controller hierarchy in some sort of container/window. It is also responsible for managing the titlebar stack in the presented window.
open class PresentationController {

	public var _container: Container?

	public var container: Container! {
		get {
			if _container == nil {
				generateContainer()
			}
			print("container: \(_container)")
			return _container
		}
		set {
			_container = newValue
		}
	}

	public var delegate: PresentationDelegate?

	public var presentingController: WidgetController?

	public var presentedController: WidgetController?

	private var _headerbarStack: HeaderbarStack?

	public var headerbarStack: HeaderbarStack? {
		get {
			if canShowHeaderBar, showsHeaderbar, _headerbarStack == nil {
				_headerbarStack = buildHeaderbarStack()
			}
			return _headerbarStack
		}
	}

	/// Indicates whether a presentation controller has the ability to show headerbars
	open var canShowHeaderBar: Bool {
		return false
	}

	/// A variable to determining whether the headerbar should be displayed, if possible
	public var showsHeaderbar: Bool = true {
		didSet {
			if canShowHeaderBar, showsHeaderbar, !oldValue {
				showHeaderbar()
			} else if canShowHeaderBar, !showsHeaderbar, oldValue {
				hideHeaderbar()
				_headerbarStack = nil
			}
		}
	}

	open func beginPresentation() {

	}

	open func endPresentation() {

	}

	open func generateContainer() {

	}

	open func buildHeaderbarStack() -> HeaderbarStack {
		return HeaderbarStack()
	}

	open func install(controller: WidgetController) {
		presentedController = controller
		installContent()
		setupHeader()
		refreshHeader()
	}

	open func installContent() {
		guard let presentedController = presentedController else {
			return
		}
		container.add(widget: presentedController.widget)
		presentedController.widget.showAll()
	}

	open func showHeaderbar() {

	}

	open func hideHeaderbar() {

	}

	open func setupHeader() {
		guard let headerbarStack = headerbarStack else {
			return
		}
		headerbarStack.setupComplexHeaderbar(using: presentedController?.setupComplexHeaderbar())
	}

	open func refreshHeader() {
		guard let headerbarStack = headerbarStack else {
			return
		}
		headerbarStack.update(with: presentedController?.headerbarState())
	}

	public func ancestor<T: PresentationController>(ofType type: T.Type) -> T? {
		var current = presentingController?.presentingController
		while current != nil {
			if let target = current as? T {
				return target
			} else {
				current = current?.presentingController?.presentingController
			}

		}
		return nil
	}

}
