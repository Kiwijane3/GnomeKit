import Foundation
import Gtk
import GtkKit

public class CollectionTestController: CollectionWidgetController<String, String> {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override func widgetDidLoad() {
		print(isDarkTheme())
		headerbarItem.endItems = [
			BarButtonItem(iconName: "list-add-symbolic", onClick: { (button) in
				debugPrint("Testing button clicked")
			})
		]
		setSections(to: [
			"First Section"
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
		let overlay: Frame = buildWidget(named: "glade_test_box")
		let label: Label = overlay.child(named: "test_label")
		label.text = item
		return overlay
	}

	public override func generateLayout(for section: String) -> CollectionLayoutSection {
		return CollectionLayoutFlowSection(rowSpacing: 8, columnSpacing: 8, orientation: .init(0), minChildren: 1, maxChildren: 10, homogenous: false)
	}

	public override func activate(in section: Int, at index: Int) {
	    let controller = LabelController(text: "\(section):\(index)")
	    navigationController?.push(controller)
	}

}
