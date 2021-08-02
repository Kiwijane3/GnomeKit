import Foundation
import Gtk
import Cairo

open class PrintPageRenderer {

	public init() {}

	/**
		The number of pages to be printed
	*/
	open var numberOfPages: Int  {
		return -1
	}

	/**
		The total size of the paper being printed onto
	*/
	public internal(set) var paperRect: CGRect = .zero


	/**
		The area of the paper onto which the selected printer can print
	*/
	public internal(set) var printableRect: CGRect = .zero

	/**
		Prepares for printing. If the number of pages your application is printing depends on the page configuration, numberOfPages should be a positive number after this function
	*/
	open func prepare() {}

	/**
		Prints the page at `index` onto `context`

		- Parameter printableRect: The rect which can be printed onto
	*/
	open func drawPage(at index: Int, in printableRect: CGRect, using context: ContextProtocol) {}

}
