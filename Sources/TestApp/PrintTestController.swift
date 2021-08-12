import Foundation
import Gtk
import GtkKit
import Cairo

public class PrintTestController: WidgetController {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override var widgetName: String {
		return "print_test"
	}

	lazy var printButton: Button = child(named: "print_button")

	public override func widgetDidLoad() {
		printButton.onClicked(handler: onPrint(_:))
		headerbarItem.endItems = [BarButtonItem(iconName: "penguin-symbolic")]
	}

	func onPrint(_ button: ButtonRef) {
		present(PrintInteractionController(renderer: TestRenderer()))
	}

}

public class TestRenderer: PrintPageRenderer {

	public override var numberOfPages: Int {
		return 1
	}

	public override func drawPage(at index: Int, in printableRect: CGRect, using context: ContextProtocol) {
		let xCenter = paperRect.size.width / 2
		print(xCenter)
		let yCenter = paperRect.size.height / 2
		print(yCenter)
		let text = "Hello World!"
		let testSize = text.size
		let xOrigin = xCenter - (testSize.width / 2)
		let yOrigin = yCenter - (testSize.height / 2)
		text.draw(at: CGPoint(x: xOrigin, y: yOrigin), in: context)
	}

}
