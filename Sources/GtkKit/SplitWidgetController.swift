import Gtk

public class SplitWidgetController: WidgetController {

	private var box: Box! {
		return widget as! Box
	}

	private var primaryRevealer: Revealer?

	private var primarySizeGroup: SizeGroup?

	private var secondaryBox: Box?

	/// Whether the header bar should tell the presentation controller to display each of its children's headerbar items in a split configuration. This is only possible when the SplitWidgetController is the root of the presentation context.
	/// If the split header is not used, then the primary controller's child is the only one shown.
	public var usesSplitHeader: Bool = true

	public init(primary: WidgetController, secondary: WidgetController? = nil) {
		super.init()
		primaryChild = primary
		secondaryChild = secondary
		addChild(primaryChild!)
		if let secondaryChild = secondaryChild {
			addChild(secondaryChild)
		}
	}

	public override func loadWidget() {
		widget = Box(orientation: .horizontal, spacing: 0)
		primaryRevealer = Revealer()
		primaryRevealer?.transitionType = .slideRight
		primarySizeGroup = SizeGroup(mode: .horizontal)
		primarySizeGroup?.add(widget: primaryRevealer!)
		primaryRevealer?.revealChild = true
		box.packStart(child: primaryRevealer!, expand: false, fill: true, padding: 0)
		box.packStart(child: HSeparator(), expand: false, fill: false, padding: 0)
		secondaryBox = Box(orientation: .horizontal, spacing: 0)
		box.packStart(child: secondaryBox!, expand: true, fill: true, padding: 0)
		installPrimary()
		installSecondary()
	}

	private func installPrimary() {
		guard let primaryChild = primaryChild else {
			return
		}
		primaryRevealer?.removeAllChildren()
		primaryRevealer?.add(widget: primaryChild.widget)
		primaryRevealer?.showAll()
	}

	private func installSecondary() {
		guard let secondaryChild = secondaryChild else {
			return
		}
		secondaryBox?.removeAllChildren()
		secondaryBox?.packStart(child: secondaryChild.widget, expand: true, fill: true, padding: 0)
	}

	public override func show(_ controller: WidgetController) {
		if let primaryChild = primaryChild {
			removeChild(primaryChild)
		}
		addChild(controller)
		primaryChild = controller
		installPrimary()
		primaryRevealer?.revealChild = true
		headerNeedsRefresh()
	}

	public override func showSecondaryViewController(_ controller: WidgetController) {
		if let secondaryChild = secondaryChild {
			removeChild(secondaryChild)
		}
		print("Installing \(controller) as secondary child")
		addChild(controller)
		secondaryChild = controller
		installSecondary()
		headerNeedsRefresh()
	}

	public func expandPrimary() {
		primaryRevealer?.revealChild = true
	}

	public func collapsePrimary() {
		primaryRevealer?.revealChild = false
	}
	public func togglePrimary() {
		guard let primaryRevealer = primaryRevealer else {
			return
		}
		primaryRevealer.revealChild = !primaryRevealer.revealChild
	}

	open override func headerbarState() -> HeaderbarState {
		print("headerbarState() called while secondaryChild was: \(secondaryChild)")
		return .complex(states: [primaryChild?.headerbarState(), secondaryChild?.headerbarState()])
	}

	open override func setupComplexHeaderbar() -> (Widget, [HeaderbarStack])? {
		print("setupComplexHeaderbar()")
		let box = Box(orientation: .horizontal, spacing: 0)
		let headerRevealer = Revealer()
		// We assume that headerbar setup occurs after the widget is loaded. PresentationControllers should ensure this is the case.
		primarySizeGroup?.add(widget: headerRevealer)
		primaryRevealer?.bind(RevealerPropertyName.revealChild, target: headerRevealer, property: RevealerPropertyName.revealChild, flags: .syncCreate)
		primaryRevealer?.bind(RevealerPropertyName.transitionType, target: headerRevealer, property: RevealerPropertyName.transitionType, flags: .syncCreate)
		primaryRevealer?.bind(RevealerPropertyName.transitionDuration, target: headerRevealer, property: RevealerPropertyName.transitionDuration, flags: .syncCreate)
		let primaryHeaderbarStack = HeaderbarStack()
		headerRevealer.add(widget: primaryHeaderbarStack)
		box.packStart(child: headerRevealer, expand: false, fill: false, padding: 0)
		box.packStart(child: HSeparator(), expand: false, fill: false, padding: 0)
		let secondaryHeaderbarStack = HeaderbarStack()
		box.packStart(child: secondaryHeaderbarStack, expand: true, fill: true, padding: 0)
		return (box, [primaryHeaderbarStack, secondaryHeaderbarStack])
	}

}
