import Foundation
import Gtk
import GtkKit

public class MenuButtonTestController: WidgetController {

	public override func widgetDidLoad() {
		let menu = ActionMenu(children: [
				Action(title: "First Item", iconName: "auth-sim-symbolic", handler: {
					print("Selected First item")
				}),
				Action(title: "Second Item", iconName: "auth-sim-missing-symbolic", handler: {
					print("Selected Second item")
				}),
				ActionMenu(title: "Submenu", iconName: "dialog-warning-symbolic", children: [
					Action(title: "First Submenu Item", iconName: "audio-volume-low-symbolic", handler: {
						print("Selected first submenu item")
					}),
					Action(title: "Second Submenu Item", iconName: "battery-level-50-charging-symbolic", handler: {
						print("Selected second submenu item")
					})
				])
			])
		headerbarItem.endItems = [
			BarButtonItem(iconName: "open-menu-symbolic", menu: menu)
		]
		let menuButton = MenuButton(label: "Show Menu", menu: menu)
		(widget as? Container)?.add(widget: menuButton)
	}

}
