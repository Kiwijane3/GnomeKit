import Foundation
import GLibObject
import Gtk

public class SideDetailController: WidgetController {

	public var primaryChild: WidgetController?

	public var primaryContainer: Box?

	public var detailContainer: Revealer?

	public override var mainChild: WidgetController? {
		get {
			return primaryChild
		}
	}

	public override var headerbarSupplier: HeaderbarSupplier {
		get {
			primaryChild?.headerbarSupplier ?? self.headerbarItem
		}
	}

	public init(primaryChild: WidgetController, detailChild: WidgetController? = nil) {
		super.init()
		addChild(primaryChild)
		self.primaryChild = primaryChild
		if let detailChild = detailChild {
			addChild(detailChild)
			secondaryChild = detailChild
		}
	}

	public override func loadWidget() {
	    let box = Box(orientation: .horizontal, spacing: 0)
	    widget = box
	    let primaryContainer = Box(orientation: .horizontal, spacing:  0)
		self.primaryContainer = primaryContainer
	    box.packStart(child: primaryContainer, expand: true, fill: true, padding: 0)
	    box.packStart(child: Separator(orientation: .vertical), expand: false, fill: false, padding: 0)
	    let detailContainer = Revealer()
	    detailContainer.set(revealChild: false)
	    self.detailContainer = detailContainer
	    box.packEnd(child: detailContainer, expand: false, fill: false, padding: 0)
		widget.showAll()
		installPrimary()
		installDetail()
		if secondaryChild != nil {
			detailContainer.set(revealChild: true)
		}
	}

	// Installs the primary child's widget into the primaryContainer
	public func installPrimary() {
		guard let primaryChild = primaryChild, let primaryContainer = primaryContainer else {
			return
		}
		primaryContainer.removeAllChildren()
		primaryContainer.packStart(child: primaryChild.widget, expand: true, fill: true, padding: 0)
		primaryChild.installedIn(self)
		primaryContainer.showAll()
	}

	// Installs the detail child's widget into the detail controller. Does not alter the state of the revealer.
	public func installDetail() {
		guard let detailChild = secondaryChild, let detailContainer = detailContainer else {
			return
		}
		detailContainer.removeAllChildren()
		detailContainer.add(widget: detailChild.widget)
		detailChild.installedIn(self)
		detailContainer.showAll()
		parent?.mainUpdated()
	}

	public override func show(_ controller: WidgetController) {
		if let primaryChild = primaryChild {
			removeChild(primaryChild)
		}
		addChild(controller)
		primaryChild = controller
		installPrimary()
	}

	public override func showSecondaryViewController(_ controller: WidgetController) {
		debugPrint("Secondary child: \(secondaryChild)")
	 	if let secondaryChild = secondaryChild {
	 		removeChild(secondaryChild)
	 	}
		addChild(controller)
		secondaryChild = controller
		installDetail()
		displayDetail()
	}

	public var dismissalCompleteHandlerId: Int?

	public override func dismissDetailChild() -> Bool {
		guard let detailChild = secondaryChild else {
			return false
		}
		if let detailContainer = detailContainer {
			// Remove the detail child and remove its widget from the revealer once the revealer is collapsed.
			if detailContainer.childRevealed {
				// Sign up to intercept the completion of the dismissal
				dismissalCompleteHandlerId = detailContainer.onNotify(handler: { [weak self] (widget, param) in
					self?.dismissalCompleteOnNotify(param: param)
				})
				hideDetail()
				removeChild(detailChild)
			} else {
				detailContainer.removeAllChildren()
				removeChild(detailChild)
			}
		}
		return true
	}

	// Handles disposing of a removed detail controller's child once the dismissal animation is complete. This connects to a generic notify signal, so we need to check for the correct property
	public func dismissalCompleteOnNotify(param: ParamSpecRef) {
		// Once the dismissal is complete, child-revealed will be updated
		if let name = param.name, name == "child-revealed" {
			detailContainer?.removeAllChildren()
			if let detailContainer = detailContainer, let dismissalCompleteHandlerId = dismissalCompleteHandlerId {
				signalHandlerDisconnect(instance: detailContainer, handlerID: dismissalCompleteHandlerId)
			}
		}
	}

	public func displayDetail() {
		guard let detailContainer = detailContainer, let detailChild = secondaryChild else {
			return
		}
		detailContainer.transitionType = .slideLeft
		detailContainer.set(revealChild: true)
		mainChild?.onWidgetReallocated()
	}

	public func hideDetail() {
		guard let detailContainer = detailContainer, let detailChild = secondaryChild else {
			return
		}
		detailContainer.set(revealChild: false)
		mainChild?.onWidgetReallocated()
	}

}
