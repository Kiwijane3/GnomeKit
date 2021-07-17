import Foundation
import Gtk
import GtkKit

public class CollectionTestController: CollectionWidgetController<String, String> {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override func widgetDidLoad() {
		print(isDarkTheme())
		headerbarItem.title = "Collection Test"
		headerbarItem.endItems = [
			BarButtonItem(iconName: "list-add-symbolic", onClick: { [weak self] (button) in
				let alert = AlertController(title: "Test Dialog", message: "This is a test dialog")
				alert.addAction(AlertAction(title: "Cancel"))
				alert.addAction(AlertAction(title: "Suggested", style: .suggested) { (_) in
					print("Did suggested action")
				})
				alert.addEntry(configurationHandler: { (entry) in
					entry.placeholderText = "Test Text"
				})
				self?.present(alert)
			})
		]
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
	    print("Presenting")
	    show(controller)
	}

}
