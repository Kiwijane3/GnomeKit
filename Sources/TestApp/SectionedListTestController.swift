import Foundation
import Gtk
import GtkKit

public class SectionedListTestController: SectionedListController<String, String> {

	public override func widgetDidLoad() {
		headerbarItem.title = "Test List"
		setSections(to: ["First Section", "Second Section"])
		setItems(to: ["First Item", "Second Section"], in: "First Section")
		setItems(to: ["First Item", "Second Section", "Third Section"], in: "Second Section")
	}
	
	public override func generateWidget(for item: String) -> Widget {
		print("Generating widget")
		let row = ListBoxRow()
		let box = Box(orientation: .horizontal, spacing: 8)
		let label = Label(text: item)
		label.styleContext.addClass(className: "body")
		box.packStart(child: label, expand: false, fill: false, padding: 8)
		row.add(widget: box)
		row.selectable = false
		row.activatable = true
		row.setSizeRequest(width: 0, height: 32)
		return row
	}
	
	public override func title(for section: String) -> String? {
		return section
	}
	
	public override func activate(in section: Int, at index: Int) {
	    print("Activated at \(index) in \(section)")
	    navigationController?.push((SelectedController(display: "Selected item at \(index) in \(section)")))
	}
	
}
