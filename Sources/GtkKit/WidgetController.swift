//
//  WidgetController
import Foundation
import Gtk
import CGtk
import GLibObject

open class WidgetController {

	open var bundle: Bundle? {
		return nil
	}

	open var uiFile: String {
		return "ui"
	}

	open var widgetName: String? {
		return nil
	}

	public init() {

	}

	// MARK: Widgets

	private var _widget: Widget?;

	/// The root widget for the controller.
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

	/// Returns whether the widget has been loaded into the controller.
	public var isWidgetLoaded: Bool {
		get {
			return _widget != nil
		}
	}

	/// Loads the widget for the the controller
	open func loadWidget() {
		if loadWidgetFromBuilder() {
			return
		}
		widget = Grid()
	}

	// Attempts to load from the appropriate builder file. Returns true if successful
	public func loadWidgetFromBuilder() -> Bool {
		debugPrint("Attempting to load from builder")
		guard let widgetName = widgetName else {
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

	/// Called once the widget has been loaded. This can be used to perform additional setup after loading the widget, particularly when it is automated, such as when the widget is loaded from Glade.
	open func widgetDidLoad() {
		// NOOP
	}

	/// Loads the widget if it has been previously loaded.
	public final func loadWidgetIfNeeded() {
		if !isWidgetLoaded {
			loadWidget();
			widgetDidLoad()
		}
	}

	public final func root<T: Widget>(as type: T.Type) -> T! {
		loadWidgetIfNeeded();
		return T.init(retainingRaw: widget.ptr)
	}

	public final func child<T: Widget>(named name: String) -> T! {
		loadWidgetIfNeeded()
		return widget.child(named: name, of: T.self)
	}

	// MARK:- Presentation

	/// Present the controller in a main context, such as as the current controller in a NavigationController, or in the centre controller in a PanedController.
	open func show(_ controller: WidgetController) {
		parent?.show(controller)
	}

	/// Present the controller in a detail context, such as the left pane of a PanedController. This is a no-op for many controllers.
	open func showSecondaryViewController(_ controller: WidgetController) {
		parent?.showSecondaryViewController(controller)
	}

	// Present the controller in a tertiary context, such as in the right pane of PanedController. This is a no-op more often than not.
	open func showTertiaryViewController(_ controller: WidgetController) {
		parent?.showTertiaryViewController(controller)
	}

	open func present(_ controller: PresentationController) {
		presentedController = controller
		controller.beginPresentation()
	}

	/// Presents the controller modally, such as in a popup or popover. The display is controlled by the controller's ModalPresentation, if present; Otherwise, presentation is handled by the presenter.
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

	/// The ModalPresentation used to display this controller.
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

	public var presentedController: PresentationController?

	private var _presentingController: PresentationController?

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

	/// Dismisses the currently shown/presented controller, if applicable. One controller is dismissed on each call, with modally presented controllers taking priority, followed by main children if the controller can dismiss them. If no controllers can be dismissed, then the call is propagated to the parent, so child controllers can dismiss themselves.
	public func dismiss() {
		if dismissModal() {
			return;
		}
		if dismissDetailChild() {
			return
		}
		if dismissMainChild() {
			return;
		}
		parent?.dismiss();
	}

	/// Dismisses the modal controller, if there is one. Returns whether the dismissal process should be terminated; Generally, this will be true if a controller has been dismissed.
	open func dismissModal() -> Bool {
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

	/// Dismisses the main child, if one exists and the controller is capable of dismissing it. Returns whether the dismissal process should be terminated; Generally, this will be tre if a controller has been dismissed.
	open func dismissMainChild() -> Bool {
		// By default, controllers cannot dismiss their non-modal children.
		return false;
	}

	open func dismissDetailChild() -> Bool {
		return false
	}

	open func dismissTertiary() -> Bool {
		return false
	}


	// MARK:- Controller Hierarchy

	/// The main child of this controller. For most controllers, this is just self. For container controllers, it is the most prominent child, such as the currently displayed child of a NavigationController, or the Central child of a PanedController.
	/// The headerbarItem of the main child will be displayed in the headerbar by the presenting controller
	open var mainChild: WidgetController? {
		get {
			return self
		}
	}

	/// Traverses the main child chain to fetch the final controller in this chain. This will generally be the active controller.
	public var ultimateChild: WidgetController? {
		get {
			if mainChild === self {
				return self
			} else {
				return mainChild?.ultimateChild
			}
		}
	}

	/// The secondary child of this controller, if any.
	open var secondaryChild: WidgetController?;

	/// The secondary child of this controller, if any.
	open var tertiaryChild: WidgetController?;

	/// The controller currently being modally presented by this controller.
	open var modallyPresented: WidgetController?;

	/// The direct ancestor of this controller.
	public var parent: WidgetController?;

	/// Returns the most recent window controller
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

	/// All of the children of this controller.
	public var children: [WidgetController] = [];

	/// Adds the controller as a child.
	open func addChild(_ controller: WidgetController) {
		children.append(controller);
		controller.parent = self;
		print("Added child")
	}

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

	/// Called when the controller's widget is installed in the widget of its parent.
	open func installedIn(_ controller: WidgetController) {}

	/// Called when the controller is removed from its parent.
	public func removedFromParent() {}

	/// When a container controller updates its main child, such as when a navigation controller pushes or pops a controller, it should call mainUpdated() on its parent so it can perform any updates, which should propagate it to its parents until it reaches the root controller. This method is used to propagate headerbarItem updates to window controllers.
	open func mainUpdated() {
		parent?.mainUpdated();
	}

	/// This function is called when a parent controller reallocates the proportion of the screen allocated to the controller, such as when a SplitViewController hides the primary view. It is not called when the window is resized.
	open func onWidgetReallocated() {
		return
	}

	// MARK:- Items for headerbars

	/// The HeaderbarItem specifies items to be displayed in the header bar when the controller is the main child
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

	/// The tab item can be used to specify the title and image used to identify the controller in a tab controller.
	public var tabItem: TabItem = TabItem()

	/// The supplementary item is displayed alongside the main child's item contents in the header, and is used by container controllers to provide controls for modifying the container state, such as the back button of a navigation controller.
	public var supplementaryItem: BarItem? {
		get {
			return nil
		}
	}

	/// Resolves the supplementaryItem to be displayed. This will be supplementary item of the deepest controller in the main chain with a defined item. Container controllers should not provide supplementary items in their base state so that their ancestors can dismiss them.
	public func resolveSupplementaryItem() -> BarItem? {
		if mainChild === self {
			return supplementaryItem
		} else {
			return mainChild?.resolveSupplementaryItem() ?? self.supplementaryItem
		}
	}

	/// This method causes the presenting controller to update the state of the headerbar.
	public func headerNeedsRefresh() {
		presentingController?.refreshHeader()
	}

}
