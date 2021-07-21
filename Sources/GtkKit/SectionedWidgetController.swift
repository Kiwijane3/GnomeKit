import Foundation
import Gtk

open class SectionedWidgetController<S: Hashable, I: Hashable>: WidgetController {

	public var model = SectionedModel<S, I>()

	public func setSections(to sections: [S]) {
		model.setSections(to: sections)
	}

	public func setItems(to items: [I], in section: S) {
		model.setItems(to: items, in: section)
	}

	open func generateWidget(for item: I) -> Widget {
		return Box(orientation: .horizontal, spacing: 0)
	}

	open func activate(in section: Int, at index: Int) {
		return
	}

	open func activate(in section: S, for item: I) {
		return
	}

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
