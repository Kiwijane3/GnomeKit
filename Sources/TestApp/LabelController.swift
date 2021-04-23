import Foundation
import Gtk
import CGtk
import GLibObject
import GtkKit

public class LabelController: WidgetController {

	public var text: String

	public init(text: String) {
		self.text = text
		super.init()
		tabItem.title = text
	}

	public override func loadWidget() {
		let label = Label(text: text)
		widget = label
		label.halign = .center
		label.valign = .center
		let grid = Grid()
		gtk_container_get_type()
		let gridIsAContainer = typeIsA(type: grid.type, isAType: gtk_container_get_type())
		debugPrint("Grid is a container? \(gridIsAContainer)")
		let labelIsAContainer = typeIsA(type: label.type, isAType: gtk_container_get_type())
		debugPrint("Label is a container? \(labelIsAContainer)")
	}

}
