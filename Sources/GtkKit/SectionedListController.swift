import Foundation
import Gtk

open class SectionedListController<S: Hashable, I: Hashable>: WidgetController {

	public var sectionedList: SectionedListWidget<S, I>! {
		get {
			return widget as? SectionedListWidget<S, I>
		}
	}
	
	public var model = SectionedModel<S, I>()

	public override func loadWidget() {
		widget = SectionedListWidget<S, I>()
		sectionedList.model = model
		sectionedList.onCreateWidget(generateWidget(for:))
		sectionedList.onGetTitle(title(for:))
		sectionedList.onRowActivated(activate(in:at:))
		sectionedList.showAll()
		widgetDidLoad()
	}
	
	public func setSections(to sections: [S]) {
		model.setSections(to: sections)
	}
	
	public func setItems(to items: [I], in section: S){
		model.setItems(to: items, in: section)
	}
	
	open func generateWidget(for item: I) -> Widget {
		return ListBoxRow()
	}
	
	open func activate(in section: Int, at index: Int) {
		return
	}
	
	open func title(for section: S) -> String? {
		return nil
	}
 
}
