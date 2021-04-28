import Foundation
import Gtk

open class SectionedListController<S: Hashable, I: Hashable>: SectionedWidgetController<S, I> {

	public var sectionedList: SectionedListWidget<S, I>! {
		get {
			return widget as? SectionedListWidget<S, I>
		}
	}

	public override func loadWidget() {
		widget = SectionedListWidget<S, I>()
		sectionedList.model = model
		sectionedList.onCreateWidget(generateWidget(for:at:in:))
		sectionedList.onGetTitle(title(for:))
		sectionedList.onRowActivated(activate(in:at:))
		sectionedList.showAll()
	}
	
	open override func generateWidget(for item: I, at index: Int, in section: Int) -> Widget {
		return ListBoxRow()
	}
	
	open func title(for section: S) -> String? {
		return nil
	}
 
}
