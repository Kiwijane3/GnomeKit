import Foundation
import Gtk
import GtkKit

public class GladeTestController: WidgetController {

	private lazy var label: Label = child(named: "label")

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override var widgetName: String? {
		return "glade_test"
	}

	public override func widgetDidLoad() {
		debugPrint(widget.name)
		label.text = "success"
	}

}
