import Foundation
import Gtk
import GtkKit

public class SectionedListTestController: SectionedListController<String, String> {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override func widgetDidLoad() {
		headerbarItem.title = "Test List"
		setSections(to: [
			"First Section",
			"Second Section"
		])
		setItems(to: [
			"First Item",
			"Second Item",
			"Third item",
			"Fourth Item",
			"Fifth Item",
			"Sixth Item",
			"Seventh Item",
			"Eighth Item",
			"Ninth Item",
			"Tenth item"
		], in: "First Section")
		setItems(to: [
			"First item",
			"Second Item",
			"Third Item",
			"Fourth Item"
		], in: "Second Section")
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
		let controller = LabelController(text: "\(section):\(index)")
		print("parent: \(parent)")
		showSecondaryViewController(controller)
	}
	
}
