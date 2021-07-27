import Foundation
import Gtk
import GtkKit

public class DocumentPickerTestController: WidgetController {

	public override var bundle: Bundle? {
		return Bundle.module
	}

	public override var widgetName: String? {
		return "document_picker_test"
	}

	public lazy var createFileButton: Button = child(named: "create_file_button")

	public lazy var saveFileButton: Button = child(named: "save_file_button")

	public lazy var openFileButton: Button = child(named: "open_file_button")

	public override func widgetDidLoad() {
		createFileButton.onClicked(handler: showFileCreationDialog(_:))
		saveFileButton.onClicked(handler: showFileSaveDialog(_:))
		openFileButton.onClicked(handler: showFileOpenDialog(_:))
	}

	func showFileCreationDialog(_ button: ButtonRef) {
		let controller = DocumentPickerController.forCreatingFile(ofTypes: [plainText, richTextFormat], title: "Create File", onFileSelected: createFile(at:ofType:))
		present(controller)
	}

	func createFile(at url: URL, ofType type: FileType?) {
		print("Creating file at location: \(url), with type: \(type?.title ?? "No type")")
	}

	func showFileSaveDialog(_ button: ButtonRef) {
		let controller = DocumentPickerController.forSavingFile(ofType: plainText, title: "Save File", onFileSelected: saveFile(at:ofType:))
		present(controller)
	}

	func saveFile(at url: URL, ofType type: FileType?) {
		print("Saving file at location: \(url) with type: \(type?.title ?? "No Type")")
	}

	func showFileOpenDialog(_ button: ButtonRef) {
		let controller = DocumentPickerController.forOpeningFile(ofTypes: [.allTextFiles, .allFiles], title: "Open file", onFileSelected: openFile(at:ofType:))
		present(controller)
	}

	func openFile(at url: URL, ofType type: FileType?) {
		print("Opening file at location: \(url) with type: \(type?.title ?? "No Type")")
	}


}

let plainText = FileType(title: "Plain Text", fileExtension: "txt")

let richTextFormat = FileType(title: "Rich Text Format", fileExtension: "rtf")
