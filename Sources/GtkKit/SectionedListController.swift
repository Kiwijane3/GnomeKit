import Foundation
import Gtk

open class SectionedListController<S: Hashable, I: Hashable>: SectionedWidgetController<S, I> {

	/**
		The `SectionedList` managed by this controller
	*/
	public var sectionedList: SectionedListWidget<S, I>!

	public override func loadWidget() {
		if loadWidgetFromBuilder() {
			sectionedList = child(named: "sectionedList")
		} else {
			sectionedList = SectionedListWidget<S, I>()
			widget = sectionedList
		}
		sectionedList.model = model
		sectionedList.onCreateWidget(generateWidget(for:))
		sectionedList.onGetTitle(title(for:))
		sectionedList.onRowActivated(activate(in:at:))
		sectionedList.onRowActivated(activate(in:for:))
		sectionedList.onGetDecoration(decoration(for:))
		sectionedList.showAll()
	}
	
	open override func generateWidget(for item: I) -> Widget {
		return ListBoxRow()
	}
	
	/**
		Provides the title for `section`
	*/
	open func title(for section: S) -> String? {
		return nil
	}

	/**
		Provides the style for `section`
	*/
	open func decoration(for section: S) -> SectionDecoration? {
		return nil
	}
 
}
