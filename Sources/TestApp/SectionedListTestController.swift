import Foundation
import Gtk
import GtkKit

public class SectionedListTestController: SectionedListController<String, String> {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override func widgetDidLoad() {
		headerbarItem.title = "Test List"
		setSections(to: ["First Section"])
		setItems(to: ["First Item", "Second Section"], in: "First Section")
	}
	
	public override func generateWidget(for item: String) -> Widget {
		let widget: Box = buildWidget(named: "glade_test_row")
		let label: Label = widget.child(named: "label")
		label.text = item
		return widget
	}
	
	public override func title(for section: String) -> String? {
		return section
	}
	
	public override func activate(in section: Int, at index: Int) {
	    print("Activated at \(index) in \(section)")
	    navigationController?.push((SelectedController(display: "Selected item at \(index) in \(section)")))
	}
	
}
