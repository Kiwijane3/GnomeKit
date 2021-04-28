import Foundation
import Gtk

public class CollectionWidget<S: Hashable, I: Hashable>: SectionedWidget<S, I> {

	var layoutProvider: ((S) -> CollectionLayoutSection)?
	
	var headerProvider: ((S) -> Widget?)?
	
	public override func setup() {
		onCheckResize(handler: { (container) in
			debugPrint("Check Resize")
		})
	}

	public func onLayout(_ handler: @escaping (S) -> CollectionLayoutSection) {
		layoutProvider = handler
	}
	
	public func onCreateHeader(_ handler: @escaping (S) -> Widget?) {
		headerProvider = handler
	}
	
	public override func generateContainer(for section: S) -> Container {
		if let container = layoutProvider?(section).generateContainer() {
			if let container = container as? FlowBox {
				container.selectionMode = .none
			}
			return container
		} else {
			return ListBox()
		}
	}
	
	public override func generateHeader(for section: S) -> Widget? {
		return headerProvider?(section) 
	}

	public func calculateSize() {
		debugPrint("Successfully intercepted size allocation")
	}

}

public protocol CollectionLayoutSection {
	
	func generateContainer() -> Container

}

public class CollectionLayoutListSection: CollectionLayoutSection {

	public func generateContainer() -> Container {
	     return ListBox()
	}

}

public class CollectionLayoutFlowSection: CollectionLayoutSection {
	
	public var rowSpacing: Int
	
	public var columnSpacing: Int
	
	public var orientation: Gtk.Orientation

	public var minChildren: Int
	
	public var maxChildren: Int

	public var homogenous: Bool
	
	public init(rowSpacing: Int, columnSpacing: Int, orientation: Gtk.Orientation, minChildren: Int, maxChildren: Int, homogenous: Bool) {
		self.rowSpacing = rowSpacing
		self.columnSpacing = columnSpacing
		self.orientation = orientation
		self.minChildren = minChildren
		self.maxChildren = maxChildren
		self.homogenous = homogenous
	}
	
	public func generateContainer() -> Container {
		let flowBox = FlowBox()
		flowBox.orientation = orientation
		flowBox.rowSpacing = rowSpacing
		flowBox.columnSpacing = columnSpacing
		flowBox.minChildrenPerLine = minChildren
		flowBox.maxChildrenPerLine = maxChildren
		flowBox.homogeneous = homogenous
		return flowBox            
	}
	
}
