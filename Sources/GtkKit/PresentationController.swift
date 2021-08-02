import Foundation
import Gtk

/**
	`PresentationController` handles presenting a view controller hierarchy in some sort of container/window. It is also responsible for managing the titlebar stack in the presented window.
*/
open class PresentationController {

	public var _container: Container?

	/**
		The `Container` that is used for the presentation
	*/
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

	/**
		The `PresentationDelegate` that this controller coordinates with
	*/
	public var delegate: PresentationDelegate?

	/**
		The `WidgetController` that presented this controller.
	*/
	public var presentingController: WidgetController?

	/**
		The `WidgetController` that this controller is presenting
	*/
	public var presentedController: WidgetController?

	private var _headerbarStack: HeaderbarStack?

	/**
		The `HeaderbarStack` that is displayed in this controller's container's headerbar
	*/
	public var headerbarStack: HeaderbarStack? {
		get {
			if canShowHeaderBar, showsHeaderbar, _headerbarStack == nil {
				_headerbarStack = buildHeaderbarStack()
			}
			return _headerbarStack
		}
	}

	/**
		Indicates whether this controller has the ability to show headerbars
	*/
	open var canShowHeaderBar: Bool {
		return false
	}

	/**
		Whether the controller should present a header bar if it is able to.
	*/
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

	/**
		Begins presenting this controller's content.
	*/
	open func beginPresentation() {

	}

	/**
		Ends the presentation of this controller's content.
	*/
	open func endPresentation() {

	}


	/**
		Should be called when the container is unrealised in order to perform cleanup. If this function is overridden, the overriding definition should call `super.containerDidUnrealise``
	*/
	open func containerDidUnrealise() {
		// Reset the presented controller property of the controller that presented this controller.
		if let presentingController = presentingController, presentingController.presentedController === self {
			presentingController.presentedController = nil
		}
		// Reset the presenting controller property of the controller this controller presented.
		if let presentedController = presentedController, presentedController.presentingController === self {
			presentedController.presentingController = nil
		}
		delegate?.presentationDidEnd(self)
	}

	/**
		Creates the `Container` used to present this controller's content.
	*/
	open func generateContainer() {

	}

	/**
		Creates the `HeaderbarStack` used to present this controller's content.
	*/
	open func buildHeaderbarStack() -> HeaderbarStack {
		return HeaderbarStack()
	}

	/**
		Installs `controller`s content into this controller's container.

		- Parameter controller: The `WidgetController` to be installed in this controller's container
	*/
	open func install(controller: WidgetController) {
		presentedController = controller
		installContent()
		setupHeader()
		refreshHeader()
	}

	/**
		Places the widget of `presentedController` into this controller's container.
	*/
	open func installContent() {
		guard let presentedController = presentedController else {
			return
		}
		container.add(widget: presentedController.widget)
		presentedController.widget.showAll()
	}

	/**
		Displays this controller's titlebar, if applicable.
	*/
	open func showHeaderbar() {

	}

	/**
		Hides this controller's titlebar, if applicable.
	*/
	open func hideHeaderbar() {

	}

	/**
		Sets up this controller's `HeaderbarStack` with the configuration provided by the presented controller.
	*/
	open func setupHeader() {
		guard let headerbarStack = headerbarStack else {
			return
		}
		headerbarStack.setupComplexHeaderbar(using: presentedController?.setupComplexHeaderbar())
	}

	/**
		Updates this controller's `HeaderbarStack` with the state currently provided by the presented controller.
	*/
	open func refreshHeader() {
		guard let headerbarStack = headerbarStack else {
			return
		}
		headerbarStack.update(with: presentedController?.headerbarState())
	}

	/**
		Travels up the chain of presentation controllers to find the most recent ancestor of the given type.

		- Parameter type: The type of the ancestor to be returned

		- Returns: The most recent ancestor of the specified type
	*/
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
