import Foundation
import Gtk

public class SectionedListWidget<S: Hashable, I: Hashable>: SectionedWidget<S, I> {

	var titleProvider: ((S) -> String?)?
	
	var defaultDecoration: SectionDecoration = .frame

	var decorationProvider: ((S) -> SectionDecoration?)?

	/**
		Sets the handler that provides the section titles

		- Parameter section: The section to provide a title for.
	*/
	public func onGetTitle(_ handler: @escaping ((_ section: S) -> String?)) {
		titleProvider = handler
	}
	
	/**
		Sets the handler that provides the decoration style for each section

		- Parameter section: The section to provide a decoration style for
	*/
	public func onGetDecoration(_ handler: @escaping ((S) -> SectionDecoration?)) {
		decorationProvider = handler
	}

	public override func generateHeader(for section: S) -> Widget? {
		if let sectionTitle = titleProvider?(section) {
			let box = Box(orientation: .horizontal, spacing: 8)
			let label = Label(text: sectionTitle)
			label.styleContext.addClass(className: "heading")
			box.packStart(child: label, expand: false, fill: false, padding: 0)
			return box
		} else {
			return nil
		}
	}
	
	public override func generateContainer(for section: S) -> Container {
		let listBox = ListBox()
		let decoration = decorationProvider?(section) ?? defaultDecoration
		if decoration == .frame {
			listBox.styleContext.addClass(className: "frame")
		}
		return listBox
	}

}

public enum SectionDecoration {
	/**
		Indicates the section should have no background or border
	*/
	case none
	/**
		Indicates the item should have a background and border as defined by the active theme
	*/
	case frame
}
