import Foundation
import Gtk
import GtkKit

public class DetailTestController: WidgetController {

	public override func loadWidget() {
		let grid = Grid()
		widget = grid
		let label = Label(text: "This is the detail controller!")
		grid.attach(child: label, left: 0, top: 0, width: 1, height: 1)
		grid.showAll()
		print(grid.typeName)
		print(grid.type)
	}

}
