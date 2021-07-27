import Foundation
import Gdk
import Gtk

public protocol MenuElement {

	func getWidget() -> MenuItem

}

public class ActionMenu: MenuElement {

	public let title: String

	public let image: Image?

	public let iconName: String?

	public let children: [MenuElement]

	private var _gtkMenu: Menu?

	internal var gtkMenu: Menu {
		get {
			if _gtkMenu == nil {
				buildMenu()
			}
			return _gtkMenu!
		}
		set {
			_gtkMenu = newValue
		}
	}

	private var _menuItem: MenuItem?

	internal var menuItem: MenuItem {
		get {
			if _menuItem == nil {
				buildMenuItem()
			}
			return _menuItem!
		}
		set {
			_menuItem = newValue
		}
	}

	public init(title: String = "", image: Image? = nil, iconName: String? = nil, children: [MenuElement]) {
		self.title = title
		self.image = image
		self.iconName = iconName
		self.children = children
	}

	internal func buildMenu() {
		gtkMenu = Gtk.Menu()
		for child in children {
			gtkMenu.append(child: child.getWidget())
		}
		gtkMenu.showAll()
	}

	internal func buildMenuItem() {
		menuItem = MenuItem()
		let box = Box(orientation: .horizontal, spacing: 4)
		if let image = image {
			box.packStart(child: image, expand: false, fill: false, padding: 0)
		} else if let iconName = iconName {
			let iconImage = Image(iconName: iconName, size: .menu)
			box.packStart(child: iconImage, expand: false, fill: false, padding: 0)
		}
		let label = Label(text: title)
		box.packStart(child: label, expand: false, fill: false, padding: 0)
		menuItem.add(widget: box)
		menuItem.set(submenu: gtkMenu)
	}

	public func getWidget() -> MenuItem {
		return menuItem
	}

	public func popup() {
		gtkMenu.popupAtPointer()
	}

	public func popup<T: WidgetProtocol>(at widget: T, widgetAnchor: Gravity, menuAnchor: Gravity) {
		gtkMenu.popupAt(widget: widget, widgetAnchor: widgetAnchor, menuAnchor: menuAnchor)
	}

}

public class Action: MenuElement {

	public let title: String

	public let image: Image?

	public let iconName: String?

	public let handler: () -> Void

	private var _menuItem: MenuItem?

	internal var menuItem: MenuItem {
		get {
			if _menuItem == nil {
				buildMenuItem()
			}
			return _menuItem!
		}
		set {
			_menuItem = newValue
		}
	}

	public init(title: String = "", image: Image? = nil, iconName: String? = nil, handler: @escaping () -> Void) {
		self.title = title
		self.image = image
		self.iconName = iconName
		self.handler = handler
	}

	public func buildMenuItem() {
		menuItem = MenuItem()
		let box = Box(orientation: .horizontal, spacing: 4)
		if let image = image {
			box.packStart(child: image, expand: false, fill: false, padding: 0)
		} else if let iconName = iconName {
			let iconImage = Image(iconName: iconName, size: .menu)
			box.packStart(child: iconImage, expand: false, fill: false, padding: 0)
		}
		let label = Label(text: title)
		box.packStart(child: label, expand: false, fill: false, padding: 0)
		menuItem.add(widget: box)
		menuItem.onActivate() { [handler]  (_) in
			handler()
		}
	}

	public func getWidget() -> MenuItem {
		return menuItem
	}

}
