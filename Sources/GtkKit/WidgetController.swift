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
		The swift `Bundle` that this controller loads its interface from. This should typically be overridden to return `Bundle.module`
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
		The id of the widget in the ui file that should be loaded as this controller's widget. Make sure this corresponds to the id, not the widget name.
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

	internal func uiPath() -> String? {
		return bundle?.path(forResource: uiFile, ofType: "glade") ?? Bundle.main.path(forResource: "uiFile", ofType: "glade")
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
		Returns the `widget` as an instance of `type`. This function does not do any type-checking, so make sure `type` is correct.
	*/
	public final func root<T: Widget>(as type: T.Type) -> T! {
		loadWidgetIfNeeded();
		return T.init(retainingRaw: widget.ptr)
	}


	/**
		Returns the widget named `name` in the controller's widget hierarchy. This function doesn't check whether the widget exists or is of the specified type.
	*/
	public final func child<T: Widget>(named name: String) -> T! {
		loadWidgetIfNeeded()
		return widget.child(named: name, of: T.self)
	}

	// MARK:- Presentation

	/**
		Shows `controller` in a primary context. For instance, a `NavigationController` will push `controller` onto its navigation stack,
		and a `SplitWidgetController` will show `controller` in its master panel.
		If this controller cannot show `controller` itself, it will pass the controller on to its `parent`.
	*/
	open func show(_ controller: WidgetController) {
		parent?.show(controller)
	}

	/**
		Shows `controller` in a secondary context. For instance, a `SplitWidgetController` will show the controller in its detail panel.
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
		Presents `controller` from this controller
	*/
	open func present(_ controller: PresentationController) {
		presentedController = controller
		controller.presentingController = self
		controller.beginPresentation()
	}

	/**
		Presents `controller` using a `PresentationController`, based on the presentation style specified by `controller`'s `presentation` property.
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
		The `ModalPresentation` that specifies how this controller will be displayed when presented
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
		Dismisses a currently shown `WidgetController` or `PresentationController`, if any. One controller is dismissed on each call, with presented controllers taking priority, then controllers shown in a secondary context.
		If this controller cannot dismiss any controller, then the call is passed onto `parent`.
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
		Dismisses the presented controller, if there is one.

		- Returns: Whether the dismissal process should be terminated
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
		Dismisses a controller that has been shown in a secondary context. This will remove the controller from the controller hierarchy.
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
	*/
	open var mainChild: WidgetController? {
		get {
			return nil
		}
	}

	/**
		Returns the ultimate child
	*/
	public var ultimateChild: WidgetController? {
		get {
			return mainChild?.ultimateChild ?? self
		}
	}

	/**
		The `WidgetController` that has been shown in a primary context
	*/
	open var primaryChild: WidgetController?

	/**
		The `WidgetController` that has been shown in a secondary context
	*/
	open var secondaryChild: WidgetController?

	/**
		The `WidgetController` that has been shown in a tertiary context
	*/
	open var tertiaryChild: WidgetController?

	/**
		The `WidgetController` that has been presented using a `PresentationController`
	*/
	open var modallyPresented: WidgetController?

	/**
		The `WidgetController` that has shown or presented this controller
	*/
	public var parent: WidgetController? {
		didSet {
			print("Controller \(self) had parent set to \(parent)")
		}
	}

	/**
		The most recent ancestor `PresentationController` that is a `WindowController`
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
		var current: WidgetController? = self
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
		var current: WidgetController? = self
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
		var current: WidgetController? = self
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
		var current: WidgetController? = self
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
		Adds `controller` as a child of this controller
	*/
	open func addChild(_ controller: WidgetController) {
		print("Controller \(self) added controller \(controller)")
		children.append(controller);
		controller.parent = self;
	}


	/**
		Removes the `controller` as a child of this controller
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
		Called when this `widget` is displayed in the `widget` of `controller`, which will generally be `parent`
	*/
	open func installedIn(_ controller: WidgetController) {}

	open func onWidgetReallocated() {}

	/**
		Called when this controller has been removed as a child of `parent`
	*/
	open func removedFromParent() {}

	/**
		Indicates to `parent` that the main child of this controller has changed
	*/
	open func mainUpdated() {
		parent?.mainUpdated();
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
		The tab item specifies the elements that should be used to identify the controller in the switcher when it is displayed in a `TabController`.
	*/
	public var tabItem: TabItem = TabItem()

	/**
		An additional `BarItem` to be displayedalongside the main controller's titlebar contents. This can be used by container controllers to provide controls for thier state;
		For instance, `NavigationController` uses this property to display a back button.
	*/
	public var supplementaryItem: BarItem? {
		get {
			return nil
		}
	}


	/**
		A `BarItem` to be displayed in place of the main controller's title.
	*/
	public var headerSwitcherItem: BarItem?

	/**
		Returns the `BarItem` supplementaryItem to be displayed alongside the main controller's titlebar context. This will be `supplementaryItem` of the deepest controller in the main chain with a defined item. Container controllers should not provide supplementary items in their base state so that their ancestors can dismiss them.
	*/
	public func resolveSupplementaryItem() -> BarItem? {
		if mainChild === self {
			return supplementaryItem
		} else {
			return mainChild?.resolveSupplementaryItem() ?? self.supplementaryItem
		}
	}

	/**
		Returns the `BarItem` to be displayed in place of the main controller's title
	*/
	public func resolveHeaderSwitcherItem() -> BarItem? {
		return headerSwitcherItem ?? mainChild?.resolveHeaderSwitcherItem()
	}

	/**
		Requests that the `PresentationController` managing this controller update its titlebar to reflect the current state.
	*/
	public func headerNeedsRefresh() {
		presentingController?.refreshHeader()
	}

	/**
		Returns a `HeaderbarState` to be used to populate the titlebar. This will usually only need to be overridden if `setupComplexHeaderbar` is also overridden.
	*/
	open func headerbarState() -> HeaderbarState {
		return .simple(items: headerbarItems ?? [], main: ultimateChild?.headerbarItem, supplementaryItems: resolveSupplementaryItem(), switcherItem: resolveHeaderSwitcherItem())
	}

	/**
		This function can be overridden to provide a complex headerbar, such as a split headerbar, to be used when the controller is displayed as the root of a `PresentationController`
		If you need to update this configuration after the presentation begins, call `presentingController.refreshHeaderbarSetup()`

		- Returns: A tuple. The first element is the widget to be shown in the titlebar, which should contain `HeaderbarStack`s.
			The second parameter is the list of displayed `HeaderbarStack`s, with the order corresponding to the order of headerbar states returend by `headerbarState()`
	*/
	open func setupComplexHeaderbar() -> (Widget, [HeaderbarStack])? {
		return nil
	}

	// MARK:- KeyCommands

}
