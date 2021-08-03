import Foundation
import Gtk

public class PrintInteractionController: PresentationController {

	var operation: PrintOperation?

	/**

	*/
	public var printPageRenderer: PrintPageRenderer?

	public var printInfo: PrintInfo?

	public var showsNumberOfPages: Bool = true

	public var showsPaperSelectionForLoadedPapers: Bool = true

	public init(renderer: PrintPageRenderer? = nil, info: PrintInfo? = nil) {
		self.printPageRenderer = renderer
		self.printInfo = info
	}

	public override func beginPresentation() {
		guard let printPageRenderer = printPageRenderer else {
			print("Warning: Attempted to show print dialog without printable contents")
			return
		}
		let operation = PrintOperation()
		self.operation = operation
		operation.set(unit: .points)
		operation.embedPageSetup = showsPaperSelectionForLoadedPapers
		let settings = PrintSettings()
		printInfo?.apply(to: settings)
		operation.set(printSettings: settings)
		operation.set(nPages: printPageRenderer.numberOfPages)
		operation.setUse(fullPage: true)
		operation.onBeginPrint() { [printPageRenderer] (operation, context) in
			let paperConfig = Self.paperConfig(for: context)
			printPageRenderer.paperRect = paperConfig.paperRect
			printPageRenderer.printableRect = paperConfig.printableRect
			printPageRenderer.prepare()
			operation.set(nPages: printPageRenderer.numberOfPages)
		}
		operation.onDrawPage() { [printPageRenderer] (operation, context, index) in
			let paperConfig = Self.paperConfig(for: context)
			printPageRenderer.paperRect = paperConfig.paperRect
			printPageRenderer.printableRect = paperConfig.printableRect
			printPageRenderer.drawPage(at: index, in: paperConfig.printableRect, using: context.getCairoContext()!)
		}
		operation.onDone() { [weak self] (_, result) in
			self?.containerDidUnrealise()
		}
		do {
			if let window = ancestor(ofType: WindowController.self)?.window {
				try operation.run(action: .printDialog, parent: window)
			} else {
				try operation.run(action: .printDialog)
			}
		} catch {
			print("Could not print, error: \(error)")
			containerDidUnrealise()
		}
	}

	public override func endPresentation() {
		operation?.cancel()
	}

	public override func containerDidUnrealise() {
		super.containerDidUnrealise()
		operation = nil
	}

	static internal func paperConfig(for context: PrintContextProtocol) -> (paperRect: CGRect, printableRect: CGRect) {
		let pageSetup = context.pageSetup!
		let width = pageSetup.getPaperWidth(unit: .points)
		let height = pageSetup.getPaperHeight(unit: .points)
		let paperRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
		let topMargin = pageSetup.getTopMargin(unit: .points)
		let leftMargin = pageSetup.getLeftMargin(unit: .points)
		let printableWidth = pageSetup.getPageWidth(unit: .points)
		let printableHeight = pageSetup.getPageHeight(unit: .points)
		let printableRect = CGRect(origin: CGPoint(x: topMargin, y: leftMargin), size: CGSize(width: printableWidth, height: printableHeight))
		return (paperRect: paperRect, printableRect: printableRect)
	}

}
