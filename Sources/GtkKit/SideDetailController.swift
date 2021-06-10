import Foundation
import GLibObject
import Gtk

public class SideDetailController: WidgetController {

	public var primaryChild: WidgetController?

	public var primaryContainer: Box?

	public var detailRevealer: Revealer?

	public var detailStack: Stack?

	public var detailWidget: Widget?

	public var previousDetailWidget: Widget?

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
	    let detailRevealer = Revealer()
	    self.detailRevealer = detailRevealer
	    detailRevealer.set(revealChild: false)
	    let detailStack = Stack()
	    self.detailStack = detailStack
	    detailRevealer.add(widget: detailStack)
	    box.packEnd(child: detailRevealer, expand: false, fill: false, padding: 0)
		widget.showAll()
		installPrimary()
		installDetail()
		if secondaryChild != nil {
			detailRevealer.set(revealChild: true)
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
		guard let detailChild = secondaryChild, let detailStack = detailStack, let detailRevealer = detailRevealer else {
			return
		}
		previousDetailWidget = detailWidget
		detailWidget = detailChild.widget
		detailStack.add(widget: detailWidget!)
		detailRevealer.showAll()
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
	 	if let secondaryChild = secondaryChild {
	 		removeChild(secondaryChild)
	 	}
		addChild(controller)
		secondaryChild = controller
		installDetail()
		transitionDetailChild()
		displayDetail()
	}

	public var stackTransitionCompleteHandlerId: Int?

	/// Transitions the detail stack to show the current detail widget.
	private func transitionDetailChild() {
		guard let detailRevealer = detailRevealer, let detailStack = detailStack, let detailWidget = detailWidget else {
			return
		}
		// If the revealer is currently hidden, then we just set the child without animation, since the revealer will likely perform a transition itself.
		print(detailRevealer.childRevealed)
		if !detailRevealer.childRevealed {
			detailStack.transitionType = .none
			detailStack.setVisible(child: detailWidget)
			cleanupPreviousDetailWidget()
		} else {
			stackTransitionCompleteHandlerId = detailStack.onNotify(handler: { [weak self] (widget, param) in
				self?.stackTransitionCompleteOnNotify(param: param)
			})
			detailStack.transitionType = .overLeft
			detailStack.setVisible(child: detailWidget)
		}
	}

	public func stackTransitionCompleteOnNotify(param: ParamSpecRef) {
		if let name = param.name, name == "transition-running", detailStack!.transitionRunning == false {
			cleanupPreviousDetailWidget()
			if let detailStack = detailStack, let dismissalCompleteHandlerId = dismissalCompleteHandlerId {
				signalHandlerDisconnect(instance: detailStack, handlerID: dismissalCompleteHandlerId)
			}
		}
	}

	private func cleanupPreviousDetailWidget() {
		guard let detailStack = detailStack, previousDetailWidget != nil else {
			return
		}
		detailStack.remove(widget: previousDetailWidget!)
		previousDetailWidget = nil
		print("Cleaned up detail widget")
	}

	public var dismissalCompleteHandlerId: Int?

	public override func dismissDetailChild() -> Bool {
		guard let detailChild = secondaryChild else {
			return false
		}
		if let detailRevealer = detailRevealer {
			// Remove the detail child and remove its widget from the revealer once the revealer is collapsed.
			if detailRevealer.childRevealed {
				// Sign up to intercept the completion of the dismissal
				dismissalCompleteHandlerId = detailRevealer.onNotify(handler: { [weak self] (widget, param) in
					self?.dismissalCompleteOnNotify(param: param)
				})
				hideDetail()
				removeChild(detailChild)
			} else {
				detailRevealer.removeAllChildren()
				removeChild(detailChild)
			}
		}
		return true
	}

	// Handles disposing of a removed detail controller's child once the dismissal animation is complete. This connects to a generic notify signal, so we need to check for the correct property
	public func dismissalCompleteOnNotify(param: ParamSpecRef) {
		// Once the dismissal is complete, child-revealed will be updated
		if let name = param.name, name == "child-revealed" {
			detailStack?.removeAllChildren()
			if let detailRevealer = detailRevealer, let dismissalCompleteHandlerId = dismissalCompleteHandlerId {
				signalHandlerDisconnect(instance: detailRevealer, handlerID: dismissalCompleteHandlerId)
			}
		}
	}

	public func displayDetail() {
		guard let detailRevealer = detailRevealer, let detailChild = secondaryChild else {
			return
		}
		detailRevealer.transitionType = .slideLeft
		detailRevealer.set(revealChild: true)
		mainChild?.onWidgetReallocated()
	}

	public func hideDetail() {
		guard let detailContainer = detailRevealer, let detailChild = secondaryChild else {
			return
		}
		detailContainer.set(revealChild: false)
		mainChild?.onWidgetReallocated()
	}

}
