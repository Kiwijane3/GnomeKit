import Foundation
import GLibObject
import Gtk

public protocol MenuElement {

	/**
		Called by a parent `MenuElement` to allow it to install its contents.

		If you are implementing a `MenuElement` that can be used as a submenu, your implementaion should do the following:
		First, install your submenu's box in the popover. Second, set the `submenu` child property for that box to an appropriate value.
		Finally, add a button to the box to open the submenu, using `PopoverMenuProtocol.openSubmenu(name:)`, where name is the previous value.
		Also, make sure you add child `MenuElement`s after registering the box, as this allows the correct animations to be made for submenus

		- Parameter box: The box used to present the parent `MenuElement`'s children. Install your action's controls here.
		- Parameter popover: The popover used to display the menu. You can call `popdown` once your action
	*/
	func installIn(box: Box, popover: ActionMenuPopover)

}

public class ActionMenu: MenuElement {

	/// The title of the menu. For menus that are presented directly, this value is not used and can be left as default. For submenus, this must be set to a unique value, and will be displayed at the top of the menu.
	public let title: String

	/// The name of an icon to appear before the title in the buttton for opening this menu as a submenu. The GNOME platform recommends against using a icon, and to use a symbolic icon if you do.
	public let iconName: String?

	/// The components of this menu. You can include any element, including submenus.
	public let children: [MenuElement]

	/// The popover used to present this menu
	private var popover: ActionMenuPopover!

	public init(title: String = "", iconName: String? = nil, children: [MenuElement]) {
		self.title = title
		self.iconName = iconName
		self.children = children
	}

	private func buildPopover() {
		guard popover == nil else {
			return
		}
		popover = ActionMenuPopover(for: self)

		let mainBox = Box(orientation: .vertical, spacing: 0)
		popover.add(widget: mainBox)
		for child in children {
			child.installIn(box: mainBox, popover: popover)
		}
		mainBox.showAll()
		popover.openSubmenu(name: "main")
	}

	private func buildBackButton() -> Button {
		let backButton = Button()

		backButton.styleContext.addClass(className: "menu")
		backButton.relief = .none

		let backButtonContents = Box(orientation: .horizontal, spacing: 4)

		let backIndicator = Image(iconName: "pan-start-symbolic", size: .button)
		backButtonContents.packStart(child: backIndicator, expand: false, fill: false, padding: 0)

		let startSpacer = Box(orientation: .horizontal, spacing: 0)
		startSpacer.setSizeRequest(width: 2, height: -1)
		backButtonContents.packStart(child: startSpacer, expand: false, fill: false, padding: 0)

		let titleLabel = Label(text: title)
		backButtonContents.centerWidget = WidgetRef(titleLabel.widget_ptr)

		let endSpacer = Box(orientation: .horizontal, spacing: 0)
		endSpacer.setSizeRequest(width: 12, height: -1)
		backButtonContents.packEnd(child: endSpacer, expand: false, fill: false, padding: 0)

		backButtonContents.marginStart = 4
		backButtonContents.marginEnd = 4

		backButton.add(widget: backButtonContents)
		return backButton
	}

	private func buildLinkButton() -> Button {
		let linkButton = Button()

		linkButton.styleContext.addClass(className: "menu")
		linkButton.relief = .none

		let linkButtonContents = Box(orientation: .horizontal, spacing: 4)

		if let iconName = iconName {
			let icon = Image(iconName: iconName, size: .button)
			linkButtonContents.packStart(child: icon, expand: false, fill: false, padding: 0)
		}

		let label = Label(text: title)
		linkButtonContents.packStart(child: label, expand: false, fill: false, padding: 0)

		let spacer = Box(orientation: .vertical, spacing: 0)
		spacer.setSizeRequest(width: 4, height: -1)
		linkButtonContents.packStart(child: spacer, expand: false, fill: false, padding: 0)

		let linkIndicator = Image(iconName: "pan-end-symbolic", size: .button)
		linkButtonContents.packEnd(child: linkIndicator, expand: false, fill: false, padding: 0)

		linkButtonContents.marginStart = 4
		linkButtonContents.marginEnd = 4

		linkButton.add(widget: linkButtonContents)
		return linkButton
	}

	public func installIn(box: Box, popover: ActionMenuPopover) {

		let linkButton = buildLinkButton()
		linkButton.onClicked() { [weak popover, title] (_) in
			popover?.pushMenu(named: title)
		}

		box.packStart(child: linkButton, expand: false, fill: false, padding: 0)


		let submenuBox = Box(orientation: .vertical, spacing: 0)

		popover.add(widget: submenuBox)
		popover.childSetProperty(child: submenuBox, propertyName: "submenu", value: Value(title))

		let backButton = buildBackButton()
		backButton.onClicked() { [weak popover] (_) in
			popover?.popMenu()
		}
		submenuBox.packStart(child: backButton, expand: false, fill: false, padding: 0)

		// Deeper submenus should be added later, so that gtk uses the correct transitions

		for child in children {
			child.installIn(box: submenuBox, popover: popover)
		}

		submenuBox.showAll()

	}

	public func present<WidgetT: WidgetProtocol>(from widget: WidgetT) {
		buildPopover()
		popover.present(from: widget)
	}

	public func present<WidgetT: WidgetProtocol>(pointingTo point: CGPoint, in widget: WidgetT) {
		buildPopover()
		popover.present(pointingTo: point, in: widget)
	}

	public func present<WidgetT: WidgetProtocol>(pointingTo rect: CGRect, in widget: WidgetT) {
		buildPopover()
		popover.present(pointingTo: rect, in: widget)
	}

}

public class Action: MenuElement {

	public let title: String

	public let iconName: String?

	public let handler: () -> Void

	public init(title: String = "", iconName: String? = nil, handler: @escaping () -> Void) {
		self.title = title
		self.iconName = iconName
		self.handler = handler
	}

	public func installIn(box: Box, popover: ActionMenuPopover) {
		let button = Button()

		button.styleContext.addClass(className: "menu")
		button.relief = .none

		let contents = Box(orientation: .horizontal, spacing: 4)

		if let iconName = iconName {
			let icon = Image(iconName: iconName, size: .button)
			contents.packStart(child: icon, expand: false, fill: false, padding: 0)
		}

		let label = Label(text: title)
		contents.packStart(child: label, expand: false, fill: false, padding: 0)

		contents.marginStart = 4
		contents.marginEnd = 4

		button.add(widget: contents)

		button.onClicked() { [weak popover, handler] (_) in
			handler()
			popover?.popdown()
		}

		box.packStart(child: button, expand: false, fill: false, padding: 0)

	}

}

public class MenuSeparator: MenuElement {

	public init() {

	}

	public func installIn(box: Box, popover: ActionMenuPopover) {
		let separator = Separator(orientation: .vertical)
		separator.marginStart = 4
		separator.marginEnd = 4
		box.packStart(child: separator, expand: false, fill: false, padding: 0)
	}

}


public class ActionMenuPopover: PopoverMenu {

	private var stack: [String]

	private var closeSignalId: Int?

	/// The `ActionMenu` that uses this `ActionMenuPopover`. Stored so we can manage its lifecycle manually, as we want to keep it alive while the popover is presented.
	weak var menu: ActionMenu?

	public func pushMenu(named name: String) {
		stack.append(name)
		openSubmenu(name: stack.last)
	}

	public func popMenu() {
		// Do not pop from root
		guard stack.count > 1 else {
			return
		}
		stack.popLast()
		openSubmenu(name: stack.last)
	}

	internal init(for menu: ActionMenu?) {
		stack = ["main"]

		super.init()
		becomeSwiftObj()
	}

	internal required init(raw: UnsafeMutableRawPointer) {
		stack = ["main"]
		super.init(raw: raw)
		becomeSwiftObj()
	}

	internal required init(retainingRaw raw: UnsafeMutableRawPointer) {
		stack = ["main"]
		super.init(retainingRaw: raw)
		becomeSwiftObj()
	}

	internal func present<WidgetT: WidgetProtocol>(from widget: WidgetT) {
		set(relativeTo: widget)
		present()
	}

	public func present<WidgetT: WidgetProtocol>(pointingTo point: CGPoint, in widget: WidgetT) {
		set(relativeTo: widget)
		set(pointingTo: point)
		present()
	}

	public func present<WidgetT: WidgetProtocol>(pointingTo rect: CGRect, in widget: WidgetT) {
		set(relativeTo: widget)
		set(pointingTo: rect)
		present()
	}

	public func present() {
		// Create a reference to make sure the popover remains in memory until it is dismissed
		//ref()
		retainMenu()
		stack = ["main"]
		popup()
		// NOTE:- For some reason, calling showAll before popup stops the popover from dismissing via outside clicks until it is manually closed
		// So we call showAll here.
		// Release previous reference once presentation is done.
		/**closeSignalId = onClosed() { [unowned self] (_) in
			print("closed")
			guard let closeSignalId = closeSignalId else {
				return
			}
			signalHandlerDisconnect(handlerID: closeSignalId)
			releaseMenu()
			// unref()
		}*/
	}

	public func retainMenu() {
		guard let menu = menu else {
			return
		}
		Unmanaged.passUnretained(menu).retain()
	}

	public func releaseMenu() {
		guard let menu = menu else {
			return
		}

		Unmanaged.passUnretained(menu).release()
	}

	public func close() {
		popdown()
	}

}
