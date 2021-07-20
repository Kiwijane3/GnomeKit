//
//  WidgetController
import Foundation
import Gtk
import CGtk
import GLibObject

/**
	Widget controller is the base class for all controllers. It can be used to manage a widget hierarchy, perform presentations, and has other automatic functionality.
	If you don't need the functionality of another kind of controller, WidgetController is the best base class for your custom controllers.
*/
open class WidgetController {

	/**
		The swift bundle that this controller loads its interface from. This will typically be `Bundle.module`
	*/
	open var bundle: Bundle? {
		return nil
	}

	/**
		The file name of the ui file this controller loads its interface from. This defaults to `ui`. Make sure to include the file referenced here as a bundle resource
	*/
	open var uiFile: String {
		return "ui"
	}

	/**
		The id of the widget in the ui file that this controller loads it widget from. Make sure this corresponds to the id, not the widget name.
	*/
	open var widgetName: String? {
		return nil
	}

	public init() {

	}

	// MARK: Widgets

	private var _widget: Widget?;

	/**
		The root widget for the controller.
		*/
	public var widget: Widget {
		get {
			if let _widget = _widget {
				return _widget
			} else {
				loadWidget()
				widgetDidLoad()
				return _widget!
			}
		}
		set {
			_widget = newValue
		}
	}

	/**
		Returns whether the widget has been loaded into the controller.
	*/
	public var isWidgetLoaded: Bool {
		get {
			return _widget != nil
		}
	}

	/**
		Called to load the widget for this controller. If you want to create a widget programmatically, override this function to create it.
	*/
	open func loadWidget() {
		if loadWidgetFromBuilder() {
			return
		}
		widget = Grid()
	}

	/**
		Attempts to load the widget specified by `widgetName` from the ui file. Returns true if successful
	*/
	internal func loadWidgetFromBuilder() -> Bool {
		debugPrint("Attempting to load from builder")
		guard let widgetName = widgetName else {
			print("Could not load")
			return false
		}
		guard let bundle = bundle else {
			return false
		}
		guard let uiPath = bundle.path(forResource: uiFile, ofType: "glade") else {
			return false
		}
		debugPrint("Loading from uiPath \(uiPath)")
		let builder = Builder(file: uiPath)
		guard let object = builder.getObject(name: widgetName), object.isAWidget() else {
			return false
		}
		widget = Widget(retainingRaw: object.ptr)
		debugPrint("Successfully loaded widget")
		return true
	}

	/**
		Called once the widget has been loaded. This can be used to perform additional setup after loading the widget, particularly when it is automated, such as when the widget is loaded from a ui file
	*/
	open func widgetDidLoad() {
		// NOOP
	}

	/**
		Loads the widget if it has not been previously loaded.
	*/
	public final func loadWidgetIfNeeded() {
		if !isWidgetLoaded {
			loadWidget();
			widgetDidLoad()
		}
	}

	/**
		Returns the controller's widget as the given type. This function does not do any type-checking, so make sure the type is correct.

		- Parameter type: The type the widget is returned as

		- Returns: The controller's root widget as the specified type
	*/
	public final func root<T: Widget>(as type: T.Type) -> T! {
		loadWidgetIfNeeded();
		return T.init(retainingRaw: widget.ptr)
	}


	/**
		Returns the widget with the specified name in the controller's widget hierarchy. This function doesn't check whether the widget exists or is of the specified type.

		- Parameter name: The name of the widget to be looked up in the controller's widget hierarchy

		- Returns: The widget with the specified name
	*/
	public final func child<T: Widget>(named name: String) -> T! {
		loadWidgetIfNeeded()
		return widget.child(named: name, of: T.self)
	}

	// MARK:- Presentation

	/**
		Shows the specified controller in a primary context. For instance, a navigation controller will push the specified controller onto its navigation stack,
		and a SplitWidgetController will show the controller in its master panel.
		If this controller cannot show the controller itself, it will pass the controller on to its parent.

		- Parameter controller: The controller to be shown in a primary context
	*/
	open func show(_ controller: WidgetController) {
		parent?.show(controller)
	}

	/**
		Shows the specified controller in a secondary context. For instance, a SplitWidgetController will show the controller in its detail panel.
		If this controller cannot show the controller itself, it will pass the controller on its parent.

		- Parameter controller: The controller to be shown in a secondary context
	*/
	open func showSecondaryViewController(_ controller: WidgetController) {
		parent?.showSecondaryViewController(controller)
	}

	/**
	 	Shows the controller in a tertiary context. Currently, no container controllers implement this functionality.

	 	- Parameter controller: The controller to be shown in a tertiary context
	*/
	open func showTertiaryViewController(_ controller: WidgetController) {
		parent?.showTertiaryViewController(controller)
	}

	/**
		Presents the specified presentation controller from this controller.

		- Parameter controller: The presentation controller to be presented
	*/
	open func present(_ controller: PresentationController) {
		presentedController = controller
		controller.presentingController = self
		controller.beginPresentation()
	}

	/**
		Presents the specified controller in a modal presentation, based on the presentation style specified by that controller's `presentation` property.

		- Parameter controller: The controller to be presented modally
	*/
	open func present(_ controller: WidgetController) {
		addChild(controller)
		print("Added child")
		presentedController = createPresentationController(for: controller.presentation)
		print("Created presentation controller: \(presentedController)")
		presentedController!.presentingController = self
		presentedController!.install(controller: controller)
		print("Installed controller in presentation controller")
		presentedController!.beginPresentation()
		print("Presented")
	}

	private var _presentation: ModalPresentation?;

	/**
		The `ModalPresentation` that specifies how this controller will be displayed when presented by another controller.
	*/
	public var presentation: ModalPresentation {
		get {
			if let _presentation = _presentation {
				return _presentation;
			} else {
				let presentation = ModalPresentation()
				_presentation = presentation
				return presentation
			}
		}
	}

	/**
		The `PresentationController` that presented this controller
	*/
	public var presentedController: PresentationController?

	private var _presentingController: PresentationController?

	/**
		The `PresentationController` that this controller is presently presenting
	*/
	public var presentingController: PresentationController? {
		get {
			if let presentingController = _presentingController {
				return presentingController
			}
			else {
				return parent?.presentingController
			}
		}
		set {
			_presentingController = newValue
		}
	}

	/**
		Dismisses the currently shown/presented controller, if any. One controller is dismissed on each call, with modally presented controllers taking priority, the controllers in a secondary context.
		If this controller cannot dismiss any controller, then the call is passed onto the parent controller.
	*/
	public func dismiss() {
		if dismissModal() {
			return;
		}
		if dismissDetailChild() {
			return
		}
		parent?.dismiss();
	}

	/**
		Dismisses the modal controller, if there is one. Returns whether the dismissal process should be terminated; Generally, this will be true if a controller has been dismissed.
	*/
	internal func dismissModal() -> Bool {
		guard let presentedController = presentedController else {
			return false
		}
		presentedController.endPresentation()
		if let dismissedWidgetController = presentedController.presentedController {
			removeChild(dismissedWidgetController)
		}
		self.presentedController = nil
		return true
	}

	/**
		Dismisses a controller that has been presented in a secondary context. This will remove the controller from the controller hierarchy. Returns whether the dismissal process should be terminated; Generally, this will be true if a controller has been dismissed
	.

		- Returns: Whether the dismissal process should be terminated
	*/
	open func dismissDetailChild() -> Bool {
		return false
	}


	// MARK:- Controller Hierarchy

	/**
		The main child of this controller. For non-container controllers, this will be nil. For container controllers, this will be the most prominent child.
		For instance, a `NavigationController` will return the controller currently at the top of its stack.

		- Returns: The main child of this controller.
	*/
	open var mainChild: WidgetController? {
		get {
			return nil
		}
	}

	/**
		Traverses the main child chain to fetch the final controller in this chain

		- Returns: The ultimate child of this controller
	*/
	public var ultimateChild: WidgetController? {
		get {
			return mainChild?.ultimateChild ?? self
		}
	}

	/**
		The controller that has been shown in a primary context
	*/
	open var primaryChild: WidgetController?

	/**
		The controller that has been shown in a secondary context
	*/
	open var secondaryChild: WidgetController?

	/**
		The controller that has been shown in a tertiary context
	*/
	open var tertiaryChild: WidgetController?

	/**
		The controller that has been presented modally
	*/
	open var modallyPresented: WidgetController?

	/**
		The direct ancestor of this controller.
	*/
	public var parent: WidgetController?;

	/**
		The most recent window controller
	*/
	public var windowController: WindowController? {
		// Check the most recent presenting controller
		var presentingController = presentingController
		while presentingController != nil {
			// If it is a window controller, return that
			if let windowController = presentingController as? WindowController {
				return windowController
			}
			// Else, check the presenting controller of the controller the presented the most recent presentation.
			presentingController = presentingController!.presentingController?.presentingController
		}
		return nil
	}

	/*
		The most recent ancestor of this controller that is a `NavigationController`
	*/
	public var navigationController: NavigationController? {
		var current = parent
		while let ancestor = current {
			if let navigationController = ancestor as? NavigationController {
				return navigationController
			}
			current = ancestor.parent
		}
		return nil
	}

	/**
		The most recent ancestor of this controller that is a `TabController`
	*/
	public var tabController: TabController? {
		var current = parent
		while let ancestor = current {
			if let tabController = ancestor as? TabController {
				return tabController
			}
			current = ancestor.parent
		}
		return nil
	}

	/**
		The most recent ancestor of this controller that is a `SideDetailController`
	*/
	public var sideDetailController: SideDetailController? {
		var current = parent
		while let ancestor = current {
			if let sideDetailController = ancestor as? SideDetailController {
				return sideDetailController
			}
			current = ancestor.parent
		}
		return nil
	}

	/**
		The most recent ancestor of this controller that is a `SplitWidgetControlller`
	*/
	public var splitWidgetController: SplitWidgetController? {
		var current = parent
		while let ancestor = current {
			if let splitWidgetController = ancestor as? SplitWidgetController {
				return splitWidgetController
			}
			current = ancestor.parent
		}
		return nil
	}

	/**
		All of the controllers that have been shown by this controller
	*/
	public var children: [WidgetController] = [];

	/**
		Adds the specified controller as a child of this controller

		- Parameter controller: The controller to be made a child of this controller
	*/
	open func addChild(_ controller: WidgetController) {
		children.append(controller);
		controller.parent = self;
		print("Added child")
	}


	/**
		Removes the specified controller as a child of this controller

		- Parameter controller: The controller that should be removed as a child of this controller
	*/
	open func removeChild(_ controller: WidgetController) {
		let index = children.firstIndex(where:  { (element) in
			return controller === element
		})
		if let index = index {
			children.remove(at: index)
			controller.parent = nil
			controller.removedFromParent()
		}
	}

	/**
		Called when this controller's widget is installed in the widget of its parent.

		- Parameter controller: The controller that has installed this controller's widget in its widget hierarchy
	*/
	open func installedIn(_ controller: WidgetController) {}

	/**
		Called when this controller has been removed as a child of it parent
	*/
	open func removedFromParent() {}

	/// When a container controller updates its main child, such as when a navigation controller pushes or pops a controller, it should call mainUpdated() on its parent so it can perform any updates, which should propagate it to its parents until it reaches the root controller. This method is used to propagate headerbarItem updates to window controllers.
	open func mainUpdated() {
		parent?.mainUpdated();
	}

	/**
		This function is called when a parent controller reallocates the proportion of the screen allocated to the controller, such as when a SplitViewController hides the primary view. It is not called when the window is resized.
	*/
	open func onWidgetReallocated() {
		return
	}

	// MARK:- Items for headerbars

	/**
		The `HeaderbarItem` that specifies the contents of the titlebar while this controller is the main controller in the controller hierarchy.
	*/
	public var headerbarItem: HeaderbarItem = HeaderbarItem();

	public var headerbarItems: Set<HeaderbarItem> {
		get {
			var items: Set = [headerbarItem]
			for child in children {
				items.formUnion(child.headerbarItems)
			}
			return items
		}
	}

	/**
		The tab item specifies the elements that should be used to identify the controller in the switcher when it is displayed in a tab controller.
	*/
	public var tabItem: TabItem = TabItem()

	/**
		An additional item to be displayed alongside the main controller's items in the titlebar. This can be used by container controllers to provide controls for thier state;
		For instance, `NavigationController` uses this property to display a back button.
	*/
	public var supplementaryItem: BarItem? {
		get {
			return nil
		}
	}


	/**
		An override item that is displayed in the titlebar in place of the title.
	*/
	public var headerSwitcherItem: BarItem?

	/**
		Resolves the supplementaryItem to be displayed. This will be supplementary item of the deepest controller in the main chain with a defined item. Container controllers should not provide supplementary items in their base state so that their ancestors can dismiss them.
	*/
	public func resolveSupplementaryItem() -> BarItem? {
		if mainChild === self {
			return supplementaryItem
		} else {
			return mainChild?.resolveSupplementaryItem() ?? self.supplementaryItem
		}
	}

	public func resolveHeaderSwitcherItem() -> BarItem? {
		return headerSwitcherItem ?? mainChild?.resolveHeaderSwitcherItem()
	}

	/**
		Requests that the presenting controller update its titlebar to reflect the current state.
	*/
	public func headerNeedsRefresh() {
		presentingController?.refreshHeader()
	}

	/**
		Provides the state to be displayed in the headerbar. Controllers should only need to control this if they can display a complex headerbar when displayed as the root of a presentation context.
		If your custom class overrides setupComplexHeader, then it probably needs to override this.

		- Returns: A `HeaderbarState` to be displayed in the titlebar
	*/
	open func headerbarState() -> HeaderbarState {
		return .simple(items: headerbarItems ?? [], main: ultimateChild?.headerbarItem, supplementaryItems: resolveSupplementaryItem(), switcherItem: resolveHeaderSwitcherItem())
	}

	/**
		fThis function can be overridden to provide a complex headerbar, such as a split headerbar, to be used when the controller is displayed as the root of a presentation context
		If you need to update this configuration after the presentation begins, call presentingController.refreshHeaderbarSetup()

		- Returns: A tuple. The first elemt is the widget to be shown in the titlebar, which should contain `HeaderbarStack`s.
			The second parameter is the list of displayed `HeaderbarStack`s, with the order corresponding to the order of headerbar states returend by `headerbarState()`
	*/
	open func setupComplexHeaderbar() -> (Widget, [HeaderbarStack])? {
		return nil
	}

}
