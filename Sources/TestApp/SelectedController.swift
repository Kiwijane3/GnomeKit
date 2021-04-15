import Foundation
import Gtk
import GtkKit

public class SelectedController: WidgetController {

	public var display: String

	public init(display: String) {
		self.display = display
	}
	
	public override func loadWidget() {
		let box = Box(orientation: .horizontal, spacing: 8)
		let label = Label(text: display)
		box.packStart(child: label, expand: true, fill: true, padding: 8)
		widget = box
		headerbarItem.title = display
	}
	
}
