import Foundation
import Gtk

open class SectionedWidgetController<S: Hashable, I: Hashable>: WidgetController {

	public var model = SectionedModel<S, I>()

	/**
		Updates the sections displayed to `sections`
	*/
	public func setSections(to sections: [S]) {
		model.setSections(to: sections)
	}

	/**
		Updates the contents of `sections` to `items`
	*/
	public func setItems(to items: [I], in section: S) {
		model.setItems(to: items, in: section)
	}

	/**
		Creates the widget to be displayed for `item`
	*/
	open func generateWidget(for item: I) -> Widget {
		return Box(orientation: .horizontal, spacing: 0)
	}

	/**
		Called when the user activates an element

		- Parameter section: The index of the section of the element that was activated'

		- Parameter item: The index of the element that was activated
	*/
	open func activate(in section: Int, at index: Int) {
		return
	}

	/**
		Called when the user activates an element

		- Parameter section: The section identifier of the element that was activated

		- Parameter item: The item identifier of the element that was activated.
	*/
	open func activate(in section: S, for item: I) {
		return
	}

	/**
		Loads a widget from the builder file. If you use this, make sure you declare a type for the widget and specify a builder file
		To specify a builder file, override the bundle property of this controller to the bundle containing the builder file, and override the uiFile Property if the builder file is not named ui.builder

		- Parameter name: The id of the widget to be loaded.
	*/
	public func buildWidget<T: Widget>(named name: String) -> T! {
		guard let bundle = bundle else {
			return nil
		}
		guard let uiPath = bundle.path(forResource: uiFile, ofType: "glade") else {
			return nil
		}
		let builder = Builder(file: uiPath)
		guard let object = builder.getObject(name: name) else {
			return nil
		}
		return T.init(retainingRaw: object.ptr)
	}

}
