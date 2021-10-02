import Foundation
import Gtk

public class CollectionWidget<S: Hashable, I: Hashable>: SectionedWidget<S, I> {

	var layoutProvider: ((S) -> CollectionLayoutSection)?
	
	var headerProvider: ((S) -> Widget?)?

	/**
		Sets the handler for providing the `CollectionLayoutSection`s for each section

		- Parameter section: The section to provide a `CollectionLayoutSection` for
	*/
	public func onLayout(_ handler: @escaping (_ section: S) -> CollectionLayoutSection) {
		layoutProvider = handler
	}
	
	/**
		Sets the handler for providing header widgets for each section

		- Parameter section: The section to provide a header widget for
	*/
	public func onCreateHeader(_ handler: @escaping (_ section: S) -> Widget?) {
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
	}

}

/**
	A `CollectionLayoutSection` specifies the configuration for a section in a `CollectionWidget`
*/
public protocol CollectionLayoutSection {
	
	/**
		Creates the container to be used in the `CollectionWidget`
	*/
	func generateContainer() -> Container

}

/**
	`CollectionLayoutListSection` provides a `ListBox` to be displayed in a `CollectionWidget`
*/
public class CollectionLayoutListSection: CollectionLayoutSection {

	public let decoration: SectionDecoration

	/**
		Creates a new `CollectionLayoutListSection`

		- Parameter decoration: The decoration style to be used for the section
	*/
	public init(decoration: SectionDecoration = .frame) {
		self.decoration = decoration
	}

	public func generateContainer() -> Container {
	     let listBox = ListBox()
	     if decoration == .frame {
	     	listBox.styleContext.addClass(className: "frame")
	     }
	     return listBox
	}

}


/**
	`CollectionLayoutFlowSection` provides a `FlowBox` to be displayed in a `CollectionWidget`
*/
public class CollectionLayoutFlowSection: CollectionLayoutSection {
	
	/**
		The space to be placed horizontally between the children of the section
	*/
	public let rowSpacing: Int
	
	/**
		The space to be placed vertically between the children of the section
	*/
	public let columnSpacing: Int
	
	/**
		The orientation in which the children of the section should flow
	*/
	public let orientation: Gtk.Orientation
	
	/**
		The minimum number of children to be displayed along the flowing axis. More children may be displayed if there is enough space
	*/
	public let minChildren: Int

	/**
		The maximum number of children to be displayed along the flowing axis. Fewer children may be displayed if there is not enough space
	*/
	public let maxChildren: Int

	/**
		Whether each child of the section should have the same size.
	*/
	public let homogenous: Bool
	
	/**
		Creates a new `CollectionLayoutFlowSection`

		- Parameter rowSpacing: The space to be placed horizontally between the children of the section

		- Parameter columnSpacing: The space to be placed vertically between the children of the section

		- Parameter orientation: The orientation in which the children of the section should flow

		- Parameter minChildren: The minimum number of children to be displayed along the flowing axis. More children may be displayed if there is enough space

		- Parameter maxChildren: The maximum number of children to be displayed along the flowing axis. Fewer children may be displayed if there is not enough space

		- Parameter homogenous: Whether each child of the section should have the same size.
	*/
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
