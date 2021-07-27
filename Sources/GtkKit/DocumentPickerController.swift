import Foundation
import Gtk

/**
	DocumentPickerController can be used to open, save, and create documents
*/
public class DocumentPickerController: PresentationController {

	enum Mode {
		case open
		case save
		case create
	}

	var fileChooserDialog: FileChooserDialog! {
		get {
			return container as? FileChooserDialog
		}
	}

	internal let fileTypes: [FileType]

	internal var selectedFileType: FileType? {
		get {
			guard fileTypes.count > 0 else {
				return nil
			}
			guard let filterPtr = fileChooserDialog?.filter?.ptr else {
				return nil
			}
			let filter = fileChooserDialog.filter
			let index = fileTypes.firstIndex(where: { (fileType) -> Bool in
				return fileType.fileFilter.ptr == filterPtr
			})
			if let index = index {
				return fileTypes[index]
			} else {
				return nil
			}
		}
	}

	internal let mode: Mode

	internal let title: String

	internal let onFileSelected: ((URL, FileType?) -> Void)

	/**
		A handler called when the user cancels the document picker interaction
	*/
	public var onCancel: (() -> Void)?

	required init(fileTypes: [FileType], mode: Mode, title: String, onFileSelected: @escaping (URL, FileType?) -> Void) {
		self.fileTypes = fileTypes
		self.mode = mode
		self.title = title
		self.onFileSelected = onFileSelected
		self.onCancel = nil
	}

	/**
		Creates a `DocumentPickerController` for creating a new file.

		- Parameter type: The `FileType` of the created file

		- Parameter title: The title to be displayed in document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a file

		- Parameter url: A `URL` representing the location selected by the user

		- Parameter type: The `FileType` selected by the user.

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forCreatingFile(ofType type: FileType = .allFiles, title: String, onFileSelected: @escaping (_ url: URL) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: [type], mode: .create, title: title, onFileSelected: dcWrapHandler(onFileSelected))
	}

	/**
		Creates a `DocumentPickerController` for creating a new file, allowing the user to select a format.

		- Parameter types: The `FileType`s which the user can select for the format of the new file

		- Parameter title: The title to be displayed in the document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a location to create the new file

		- Parameter url: A `URL` representing the location selected by the user

		- Parameter type: The `FileType` selected by the user.

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forCreatingFile(ofTypes types: [FileType], title: String, onFileSelected: @escaping (_ url: URL, _ type: FileType?) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: types, mode: .create, title: title, onFileSelected: onFileSelected)
	}

	/**
		Creates a `DocumentPickerController` for saving a file.

		- Parameter type: The `FileType` to save the file as

		- Parameter title: The title to be displayed in document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a location to create the new file

		- Parameter url: A `URL` representing the location selected by the user

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forSavingFile(ofType type: FileType = .allFiles, title: String, onFileSelected: @escaping (_ url: URL) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: [type], mode: .save, title: title, onFileSelected: dcWrapHandler(onFileSelected))
	}

	/**
		Creates a `DocumentPickerController` for saving a file that allows the user to select a format to save the file as.

		- Parameter types: The `FileType`s the user can select to save the file as

		- Parameter title: The title to be displayed in document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a location to save the file

		- Parameter url: A `URL` representing the location selected by the user

		- Parameter type: The `FileType` selected by the user.

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forSavingFile(ofTypes types: [FileType], title: String, onFileSelected: @escaping (_ url: URL, _ type: FileType?) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: types, mode: .save, title: title, onFileSelected: onFileSelected)
	}

	/**
		Creates a `DocumentPickerController` for opening a file of the given file type

		- Parameter type: The `FileType` which can be opened

		- Parameter title: The title to be displayed in document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a file

		- Parameter url: A `URL` representing the location of the file selected by the user

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forOpeningFile(ofType type: FileType = .allFiles, title: String, onFileSelected: @escaping (_ url: URL) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: [type], mode: .open, title: title, onFileSelected: onFileSelected)
	}

	/**
		Creates a `DocumentPickerController` for opening a file. The users can select one of several file types to filter files with.

		- Parameter types: The `FileType`s which the user can select to filter files

		- Parameter title: The title to be displayed in document picker dialog

		- Parameter onFileSelected: The handler called when the user selects a file

		- Parameter url: A `URL` representing the location of the file selected by the user

		- Returns: A new `DocumentPickerController` with the provided configuration.
	*/
	public static func forOpeningFile(ofTypes types: [FileType], title: String, onFileSelected: @escaping (_ url: URL) -> Void) -> DocumentPickerController {
		return self.init(fileTypes: types, mode: .open, title: title, onFileSelected: onFileSelected)
	}

	public override func generateContainer() {
		if let parentWindow = ancestor(ofType: WindowController.self)?.window {
			container = FileChooserDialog(title: title, parent: parentWindow, action: fileChooserAction(), firstText: "Cancel", secondText: okButtonTitle())
		} else {
			container = FileChooserDialog(title: title, firstText: "Cancel", secondText: okButtonTitle())
		}
		for fileType in fileTypes {
			fileChooserDialog.add(filter: fileType.fileFilter)
		}
		fileChooserDialog.onResponse(handler: onResponse(_:responseID:))
		fileChooserDialog.onUnrealize() { [weak self] (_) in
			self?.containerDidUnrealise()
		}
	}

	public override func beginPresentation() {
		delegate?.presentationWillBegin(self)
		container.showAll()
		delegate?.presentationDidBegin(self)
	}

	public override func endPresentation() {
		fileChooserDialog.close()
	}

	func fileChooserAction() -> FileChooserAction {
		switch mode {
			case .create, .save:
				return .save
			case .open:
				return .open
		}
	}

	func okButtonTitle() -> String {
		switch mode {
			case .create:
				return "Create"
			case .save:
				return "Save"
			case .open:
				return "Open"
		}
	}

	internal func onResponse(_ dialog: DialogRef, responseID: Int) {
		if responseID == ResponseType.ok.rawValue {
			guard let filename = fileChooserDialog.filename else {
				return
			}
			var fileURL = URL(fileURLWithPath: filename)
			if let fileExtension = selectedFileType?.fileExtension, fileURL.pathExtension != fileExtension {
				fileURL.appendPathExtension(fileExtension)
			}
			onFileSelected(fileURL, selectedFileType)
		} else {
			onCancel?()
		}
		endPresentation()
	}

}

// DocumentPickerHandler internally stores a ((URL, FileType?)) -> Void handler, but several initialisers use (URL) -> Void handler.
// This functions wraps the latter in the former for compatibility purposes
internal func dcWrapHandler(_ handler: @escaping (URL) -> Void) -> ((URL, FileType?) -> Void) {
	return { (url, _) in
  		handler(url)
	}
}

/**
	A file type refers to a specific kind of file, such as a text document or image. The file type can be specified by mime type or extension. A title can be provided
*/
public class FileType {

	/**
		A title for the file type to be displayed to the user, for instance in a document picker dialog
	*/
	public let title: String

	/**
		The mime type for this file type. Wildcards can be used; For instance "text*" will match all text documents.
	*/
	public let mimeType: String?


	/**
		The file extension for this file type
	*/
	public let fileExtension: String?

	private var _fileFilter: FileFilter?

	/**
		The underlying GtkFileFilter used to implement this file type
	*/
	public var fileFilter: FileFilter {
		get {
			if _fileFilter == nil  {
				buildFilter()
			}
			return _fileFilter!
		}
	}

	/**
		Create a new file type

		- Parameter title: The title used to describe this file type to the user
		- Parameter mimeType: The mime type for this file type. Wildcards can be used: For instance, "text*" will match all text documents
		- Parameter fileExtension: The file extension for this file type
	*/
	public init(title: String, mimeType: String? = nil, fileExtension: String? = nil) {
		self.title = title
		self.mimeType = mimeType
		self.fileExtension = fileExtension
	}

	internal func buildFilter() {
		_fileFilter = FileFilter()
		fileFilter.name = title
		if let mimeType = mimeType {
			fileFilter.add(mimeType: mimeType)
		} else if let fileExtension = fileExtension {
			fileFilter.add(pattern: "*.\(fileExtension)")
		} else {
			fileFilter.add(pattern: "*")
		}
	}

}

public extension FileType {

	static let allFiles = FileType(title: "All Files")

	static let allTextFiles = FileType(title: "All Text Files", mimeType: "text/*")

}
