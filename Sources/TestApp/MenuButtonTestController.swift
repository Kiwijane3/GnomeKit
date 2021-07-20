import Foundation
import CGtk
import Gtk
import GtkKit

public class MenuButtonTestController: WidgetController {

	public override func loadWidget() {
		widget = Box(orientation: .vertical, spacing: 0)
	}

	public override func widgetDidLoad() {
		print("Test icon loaded: \(gtk_icon_theme_has_icon(gtk_icon_theme_get_default(), "penguin-symbolic"))")
		let menu = ActionMenu(children: [
				Action(title: "First Item", iconName: "auth-sim-symbolic", handler: {
					print("Selected First item")
				}),
				Action(title: "Second Item", iconName: "penguin-symbolic", handler: {
					print("Selected Second item")
				}),
				ActionMenu(title: "Submenu", image: Image(file: Bundle.module.path(forResource: "penguin-symbolic", ofType: ".svg", inDirectory: "icons")), children: [
					Action(title: "First Submenu Item", iconName: "penguin-symbolic", handler: {
						print("Selected first submenu item")
					}),
					Action(title: "Second Submenu Item", iconName: "battery-level-50-charging-symbolic", handler: {
						print("Selected second submenu item")
					})
				])
			])
		headerbarItem.endItems = [
			BarButtonItem(iconName: "open-menu-symbolic", menu: menu),
			BarButtonItem(image: Image(file: Bundle.module.path(forResource: "penguin-symbolic", ofType: ".png", inDirectory: "icons")))
		]
		let menuButton = MenuButton(label: "Show Menu", menu: menu)
		(widget as? Box)?.packStart(child: Image(file: Bundle.module.path(forResource: "penguin-symbolic", ofType: ".svg", inDirectory: "icons")), expand: true, fill: true, padding: 0)
		(widget as? Box)?.packStart(child: menuButton, expand: false, fill: false, padding: 0)
	}

}
