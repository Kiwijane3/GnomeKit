import Foundation
import Gtk
import GtkKit

public class CenteredPrimaryTestController: WidgetController {

	public override func loadWidget() {
	    let box = Box(orientation: .vertical, spacing: 8)
	    widget = box
	    let showDetailButton = Button(label: "Show Detail")
	    showDetailButton.onClicked { [unowned self] (_) in
	    	onShowDetailClicked()
	    }
		box.packStart(child: showDetailButton, expand: false, fill: false, padding: 0)
		let dismissDetailButton = Button(label: "Dismiss Detail")
		dismissDetailButton.onClicked { [unowned self] (_) in
			onDismissDetailClicked()
		}
		box.packStart(child: dismissDetailButton, expand: false, fill: false, padding: 0)
	}

	func onShowDetailClicked() {
		showSecondaryViewController(DetailTestController())
	}

	func onDismissDetailClicked() {
		dismiss()
	}

}
