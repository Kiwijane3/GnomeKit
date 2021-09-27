import Foundation
import GLibObject
import CGtk
import Gtk
import GtkKit

public class MenuButtonTestController: WidgetController {

	var popoverMenu: PopoverMenu!

	public override func loadWidget() {
		widget = Box(orientation: .vertical, spacing: 0)
	}

	public override func widgetDidLoad() {
		let menuButton = MenuButton(label: "Show Menu", menu: ActionMenu(children: [
			Action(title: "Alpha") {
				print("Clicked Alpha")
			},
			Action(title: "Beta") {
				print("Clicked Beta")
			},
			MenuSeparator(),
			ActionMenu(title: "Submenu", children: [
				Action(title: "Delta") {
					print("Clicked Delta")
				},
				Action(title: "Omega") {
					print("Clicked Omega")
				},
				MenuSeparator(),
				ActionMenu(title: "Submenu^2", children: [
					Action(title: "Epsilon") {
						print("Clicked Epsilon")
					},
					Action(title: "Lambda") {
						print("Clicked Gamma")
					}
				])
			])
		]))
		(widget as? Box)?.packStart(child: menuButton, expand: false, fill: false, padding: 0)

		keyActions = [
			KeyAction(input: "n", modifierFlags: .control) {
				print("Pressed ctrl+n")
			}
		]

	}

	public func buildPopoverMenu() {
		popoverMenu = PopoverMenu()
		let main = Box(orientation: .vertical, spacing: 0)

		let firstButton = Button()
		firstButton.relief = .none
		firstButton.styleContext.addClass(className: "menu")
		let label = Label(text: "Action")
		label.halign = .start
		firstButton.add(widget: label)
		firstButton.onClicked() { (_) in
			print("Button one clicked")
		}
		main.packStart(child: firstButton, expand: false, fill: false, padding: 0)

		let secondButton = Button()
		secondButton.relief = .none
		secondButton.styleContext.addClass(className: "menu")
		let secondButtonBox = Box(orientation: .horizontal, spacing: 0)
		let submenuButtonLabel = Label(text: "Submenu")
		secondButtonBox.packStart(child: submenuButtonLabel, expand: false, fill: false, padding: 0)
		let submenuIndicator = Image(iconName: "go-next-symbolic", size: .button)
		secondButtonBox.packEnd(child: submenuIndicator, expand: false, fill: false, padding: 0)
		secondButton.add(widget: secondButtonBox)
		secondButton.onClicked() { [weak popoverMenu] (_) in
			print(popoverMenu)
			popoverMenu?.openSubmenu(name: "submenu")
		}
		main.packStart(child: secondButton,expand: false, fill: false, padding: 0)

		let submenu = Box(orientation: .vertical, spacing: 0)

		let backButton = Button()
		backButton.relief = .none
		backButton.styleContext.addClass(className: "menu")
		let backButtonBox = Box(orientation: .horizontal, spacing: 0)
		let backIndicator = Image(iconName: "go-previous-symbolic", size: .button)
		backButtonBox.packStart(child: backIndicator, expand: false, fill: false, padding: 0)
		let submenuNameLabel = Label(text: "Submenu")
		backButtonBox.centerWidget = WidgetRef(submenuNameLabel.widget_ptr)
		backButton.add(widget: backButtonBox)
		backButton.onClicked() { [weak popoverMenu] (_) in
			popoverMenu?.openSubmenu(name: "main")
		}
		submenu.packStart(child: backButton, expand: false, fill: false, padding: 0)

		let submenuAction = Button()
		submenuAction.relief = .none
		submenuAction.styleContext.addClass(className: "menu")
		let submenuActionLabel = Label(text: "Action")

		submenuActionLabel.halign = .start
		submenuAction.add(widget: submenuActionLabel)
		submenuAction.onClicked() { (_) in
			print("Submenu Action clicked")
			self.popoverMenu.popdown()
		}
		submenu.packStart(child: submenuAction, expand: false, fill: false, padding: 0)

		popoverMenu.add(widget: main)
		popoverMenu.add(widget: submenu)
		popoverMenu.childSetProperty(child: submenu, propertyName: "submenu", value: Value("submenu"))
		popoverMenu.showAll()
	}

	public func showPopoverMenu(_ button: ButtonProtocol) {
		popoverMenu.position = .bottom
		popoverMenu.set(relativeTo: WidgetRef(button.widget_ptr))
		popoverMenu.popup()
	}

}

