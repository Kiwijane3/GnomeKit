import Foundation
import Gtk

public class SectionedListWidget<S: Hashable, I: Hashable>: SectionedWidget<S, I> {

	var titleProvider: ((S) -> String?)?
	
	public func onGetTitle(_ handler: @escaping ((S) -> String?)) {
		titleProvider = handler
	}
	
	public override func generateHeader(for section: S) -> Widget? {
		if let sectionTitle = titleProvider?(section) {
			let box = Box(orientation: .horizontal, spacing: 8)
			let label = Label(text: sectionTitle)
			label.styleContext.addClass(className: "title-3")
			box.packStart(child: label, expand: false, fill: false, padding: 0)
			return box
		} else {
			return nil
		}
	}
	
	public override func generateContainer(for section: S) -> Container {
		let listBox = ListBox()
		listBox.styleContext.addClass(className: "frame")
		return listBox
	}

}
