import Foundation
import Gtk
import GtkKit

public class SplitSecondaryController: WidgetController {

	public override func loadWidget() {
		let box = Box(orientation: .horizontal, spacing: 0)
		let label = Label(text: "secondary")
		box.packStart(child: label, expand: true, fill: true, padding: 0)
		widget = box
	}

	public override func widgetDidLoad() {
		headerbarItem.title = "Secondary widget"
		headerbarItem.startItems = [
			BarButtonItem(iconName: "sidebar-toggle-left-symbolic", onClick: { [unowned self] (_) in
				splitWidgetController?.togglePrimary()
			})
		]
	}

}
