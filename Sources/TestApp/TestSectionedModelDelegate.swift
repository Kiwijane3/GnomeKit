import Foundation
import GtkKit

public class SectionedModelTester: SectionedModelDelegate {

	public var sectionedModel: SectionedModel<Int, Int>
	
	var sections: [Int] = []
	
	var itemsMap: [Int: [Int]] = [:]
	
	public init(sectionedModel: SectionedModel<Int, Int>) {
		self.sectionedModel = sectionedModel
		sectionedModel.delegate = self
	}
	
	public func sectionedModel(addedSection section: AnyHashable, at index: Int) {
		guard let value = section as? Int else {
			return
		}
		sections.insert(value, at: index)
		print("Added section \(section) at \(index)")
	}
	
	public func sectionedModel(removedSection section: AnyHashable, at index: Int) {
		print("Removed section at \(index)")
		sections.remove(at: index)
	}
	
	public func sectionedModel(addedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let sectionValue = section as? Int, let itemValue = item as? Int else {
			return
		}
		var items = itemsMap[sectionValue] ?? []
		items.insert(itemValue, at: index)
		itemsMap[sectionValue] = items
		print("Added item \(itemValue) at \(index) in section \(sectionValue)")
	}
	
	public func sectionedModel(removedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let sectionValue = section as? Int else {
			return
		}
		var items = itemsMap[sectionValue] ?? []
		items.remove(at: index)
		itemsMap[sectionValue] = items
		print("Removed item at index \(index) in section \(sectionValue)")
	}
	
	public func sectionedModelCompletedDispatch() {
		print("Sectioned model has indicated it has finished dispatch. Running tests")
		var errors = 0
		if sections != sectionedModel.sections {
			errors += 1
			print("Sections were not identical. Internal sections were \(sections), model had \(sectionedModel.sections)")
		}
		for section in sections {
			if itemsMap[section] != sectionedModel.items(in: section) {
				errors += 1
				print("Items for section \(section) were not identical. Internal items were \(itemsMap[section]), model had \(sectionedModel.items(in: section))")	
			}
		}
		if errors == 0 {
			print("No errors!")
		}
	}

}
