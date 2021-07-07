import Foundation
import Gtk
import CGtk
import GLibObject
import GtkKit

public class LabelController: WidgetController {

	public var text: String

	public init(text: String) {
		print("Creating label widget with text: \(text)")
		self.text = text
		super.init()
		tabItem.title = text
	}

	public override func loadWidget() {
		let label = Label(text: text)
		label.halign = .center
		label.valign = .center
		let grid = Grid()
		grid.add(widget: label)
		grid.setSizeRequest(width: 200, height: -1)
		widget = grid
	}

	public override func widgetDidLoad() {
		headerbarItem.title = "Label"
	}

}
