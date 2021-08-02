import Foundation
import DeepDiff

public class SectionedModel<S: Hashable, I: Hashable> {

	class SectionDifference {

		var section: S

		var differences: [CollectionDifference<I>.Change]

		public init(_ differences: CollectionDifference<I>, in section: S) {
			self.section = section
			self.differences = Array(differences)
		}

	}

	// The target value for sections. May not be reflected in the delegate
	var targetSections: [S]

	// The currently dispatched value for sections
	var realSections: [S]

	// The target values for the items in each section
	var targetItemsMap: [S: [I]]

	// The currently dispatched values for the items in each section
	var realItemsMap: [S: [I]]

	// The queued changes for the sections, to transition between the real values and target value
	var sectionDifferences: [CollectionDifference<S>.Change]

	var itemDifferences: [SectionDifference]

	var idleActive: Bool = false

	/**
		Whether this model has no contents.
	*/
	public var isEmpty: Bool

	/**
		The `SectionedModelDelegate` this model sends updates to
	*/
	public var delegate: SectionedModelDelegate?

	/**
		The current sections
	*/
	public var sections: [S] {
		get {
			return targetSections
		}
	}

	public init() {
		targetSections = []
		realSections = []
		targetItemsMap = [:]
		realItemsMap = [:]
		sectionDifferences = []
		itemDifferences = []
		isEmpty = true
	}

	/**
		The items that in the given section

		- Parameter section: The section to query the items in

		- Returns: The items in `section`
	*/
	public func items(in section: S) -> [I] {
		return targetItemsMap[section] ?? []
	}

	/**
		The items in the given section, as has been dispatched to the delegate.

		- Parameter section: The section to query the items in

		- Returns: The items in `section`, as has been dispatched to the delegate
	*/
	public func realItems(in section: S) -> [I] {
		return realItemsMap[section] ?? []
	}

	/**
		Gets the current index of the given section

		- Parameter section: The section to be queried

		- Returns: The current index of the given section
	*/
	public func indexOf(section: S) -> Int? {
		return targetSections.firstIndex(of: section)
	}

	/**
		Gets the current index of the item in the given section

		- Parameter item: The item to be queried

		- Parameter section: The section to find the item in

		- Returns: The index of the given item in the given section
	*/
	public func indexOf(item: I, in section: S) -> Int? {
		return items(in: section).firstIndex(of: item)
	}

	/**
		Translates an index in the data as dispatched for the given section to the index in the data as declared. Used to give application code indices that reflect their declared state

		- Parameter realIndex: The index in the dispatched data to be translated

		- Parameter section: The section of the item index to be translated

		- Returns: The translated index. If nil, this indicates that item at the real index is not present in the declared data
	*/
	public func targetIndex(forItemAtRealIndex realIndex: Int, in section: S) -> Int? {
		guard let realItems = realItemsMap[section], let targetItems = targetItemsMap[section] else {
			return nil
		}
		let item = realItems[realIndex]
		return targetItems.firstIndex(of: item)
	}

	/**
		Translates an index in the sections as dispatched to the index in the section as declared.

		- Parameter realIndex: The index in the dispatched section to be translated

		- Returns: The translated index. If nil, this indicates the section at the real index is not present in the declared sections.
	*/
	public func sectionsTargetIndex(forSectionAtRealIndex realIndex: Int) -> Int? {
		let section = realSections[realIndex]
		return targetSections.firstIndex(of: section)
	}

	/**
		Sets the sections of this model to the specified value

		- Parameter target: The new sections
	*/
	public func setSections(to target: [S]) {
		targetSections = target
		let differences = Array(targetSections.difference(from: realSections))
		sectionDifferences = differences
		if differences.count > 0 {
			startIdleIfNeeded()
		}
		calculateIsEmpty()
	}

	/**
		Sets the items in the given section to the specified value

		- Parameter target: The new items for the given section

		- Parameter section: The section to be updated.
	*/
	public func setItems(to target: [I], in section: S) {
		targetItemsMap[section] = target
		// Only calculate and dispatch the difference if the section is currently loaded. Otherwise, just retain the target and dispatch the differences when the section is loaded.
		guard targetSections.contains(section) else {
			return
		}
		// Remove any queued changes to the items as they will be obsoleted by this update
		removeChangesFromQueue(for: section)
		var realItems = realItemsMap[section]
		if realItems == nil {
			realItemsMap[section] = []
			realItems = []
		}
		let difference = target.difference(from: realItems!)
		if difference.count > 0 {
			itemDifferences.append(SectionDifference(difference, in: section))
			startIdleIfNeeded()
		}
		calculateIsEmpty()
	}

	func calculateIsEmpty() {
		let oldValue = isEmpty
		if targetSections.isEmpty {
			isEmpty = true
		} else {
			isEmpty = true
			for section in sections {
				if let targetItems = targetItemsMap[section] {
					if !targetItems.isEmpty {
						isEmpty = false
					}
				}
			}
		}
		if isEmpty != oldValue {
			delegate?.sectionedModel(isEmptyChangedTo: isEmpty)
		}
	}

	internal func applySectionChange(_ change: CollectionDifference<S>.Change) {
		switch change {
			case .insert(let offset, let element, _):
				realSections.insert(element, at: offset)
				delegate?.sectionedModel(addedSection: element, at: offset)
				// If we already have specified items for this section, set those up for dispatch
				if let targetItems = targetItemsMap[element] {
					// Set the real items to an empty array, as it is assumed the delegate has generated a new (i.e. empty) container.
					realItemsMap[element] = []
					setItems(to: targetItems, in: element)
				}
			case .remove(let offset, let element, _):
				realSections.remove(at: offset)
				delegate?.sectionedModel(removedSection: element, at: offset)
				// Remove the item changes, since the relevant element will either be removed or need to be recreated from empty
				removeChangesFromQueue(for: element)
		}
	}

	internal func applyItemChange(_ change: CollectionDifference<I>.Change, in section: S) {
		switch change {
			case .remove(let offset, let element, _):
				var items = realItemsMap[section]
				items?.remove(at: offset)
				realItemsMap[section] = items
				delegate?.sectionedModel(removedItem: element, at: offset, in: section)
			case .insert(let offset, let element, _):
				var items = realItemsMap[section]
				items?.insert(element, at: offset)
				realItemsMap[section] = items
				delegate?.sectionedModel(addedItem: element, at: offset, in: section)
		}
	}

	internal func removeChangesFromQueue(for section: S) {
		itemDifferences.removeAll(where: { (difference) in
			difference.section == section
		})
	}

	internal func startIdleIfNeeded() {
		// Make sure we aren't already executing while idle
		guard !idleActive else {
			return
		}
		idleActive = true
		idle({ [weak self] () -> Bool in
			self?.idleProcess() ?? false
		})
	}

	// Called while idling if there are changes to action to action the changes.
	internal func idleProcess() -> Bool {
		var count = 0
		while count < 10 {
			if sectionDifferences.count > 0 {
				let change = sectionDifferences.removeFirst()
				applySectionChange(change)
				count += 1
			} else if itemDifferences.count > 0 {
				var differences = itemDifferences.first!
				let change = differences.differences.removeFirst()
				applyItemChange(change, in: differences.section)
				// Remove item differences when they have been completely executed.
				if differences.differences.count == 0 {
					itemDifferences.removeFirst()
				}
				count += 1
			} else {
				delegate?.sectionedModelCompletedDispatch()
				// We have completed our process, so we can stop executing changes during idles. Setting idle active to false indicates this internally so we can restart, and returning false indicates we are done.
				idleActive = false
				return false
			}
		}
		return true
	}

}

public protocol SectionedModelDelegate {

	func sectionedModel(addedSection section: AnyHashable, at index: Int)

	func sectionedModel(removedSection: AnyHashable, at index: Int)

	func sectionedModel(addedItem item: Any, at index: Int, in section: AnyHashable)

	func sectionedModel(removedItem item: Any, at index: Int, in section: AnyHashable)

	func sectionedModelCompletedDispatch()

	func sectionedModel(isEmptyChangedTo isEmpty: Bool)

}

public extension SectionedModelDelegate {

	func sectionedModelCompletedDispatch() {
		return
	}

}
