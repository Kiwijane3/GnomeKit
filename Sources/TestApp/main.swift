import Foundation
import Gdk
import CGdk
import Gtk
import CGtk
import GtkKit

testPaperSizeConstants()
Application.run(startupHandler: nil) { (app) in
	let windowController = MainWindowController(application: Application(app))
	windowController.install(controller: PathCollisionTestController())
	windowController.beginPresentation()
	IconTheme.registerIcons(in: Bundle.module)
	print("Has test icon: \(IconTheme.getDefault().hasIcon(iconName: "penguin-symbolic"))")
}

public func testPaperSizeConstants() {
	print("Showing paper sizes for debug purposes")
	testPaperSizes(seriesName: "ISO-A", paperSizes: [
		.A0,
		.A1,
		.A2,
		.A3,
		.A4,
		.A5,
		.A6,
		.A7,
		.A8,
		.A9,
		.A10
	])
	testPaperSizes(seriesName: "ISO-B", paperSizes: [
		.B0,
		.B1,
		.B2,
		.B3,
		.B4,
		.B5,
		.B6,
		.B7,
		.B8,
		.B9,
		.B10
	])
	testPaperSizes(seriesName: "American", paperSizes: [
		.usLetter,
		.usExecutive,
		.usLegal
	])
}

public func testPaperSizes(seriesName: String, paperSizes: [PaperSize]) {
	print()
	print()
	print("=============================================================================================")
	print("================Debug Data for paper size series \(seriesName)=====================")
	print("==========================================================================================")
	for paperSize in paperSizes {
		testPaperSize(paperSize: paperSize)
	}
}

public func testPaperSize(paperSize: PaperSize) {
	print("paperSize: name: \(paperSize.name); displayName: \(paperSize.displayName); width: \(paperSize.getWidth(unit: .points)), height: \(paperSize.getHeight(unit: .points))")
}
