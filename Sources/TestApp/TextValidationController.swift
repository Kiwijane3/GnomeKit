import Foundation
import Gtk
import GtkKit

public class TextValidationController: WidgetController {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override var widgetName: String? {
		return "text_validation"
	}

	public override init() {
		super.init()
	}

	var doneButton: BarButtonItem!

	lazy var entry: Entry = child(named: "entry")

	public override func widgetDidLoad() {
		doneButton = BarButtonItem(title: "Done", onClick: onDone(_:))
		entry.onNotifyText() { [unowned self] (_, _) in
			print("active: \(entry.text != "")")
			doneButton.active = entry.text != ""
		}
		headerbarItem.endItems = [doneButton]
		doneButton.active = false
	}

	public func onDone(_ button: ButtonProtocol) {
		print("done")
	}

}

