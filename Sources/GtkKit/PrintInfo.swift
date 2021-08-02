import Foundation
import Gtk

public class PrintInfo {

	public var _duplex: PrintDuplex?

	/**
		The default duplex mode for printing
	*/
	public var duplex: PrintDuplex {
		get {
			return _duplex ?? outputType.duplex
		}
		set {
			_duplex = newValue
		}
	}

	/**
		The name of the print job
	*/
	public var jobName: String = "default"

	/**
		The default orientation for printing
	*/
	public var orientation: PrintOrientation = .portrait

	/**
		The type for the print job
	*/
	public var outputType: PrintOutputType = .general

	public var _quality: PrintQuality?

	public var quality: PrintQuality {
		get {
			return _quality ?? outputType.quality
		}
		set {
			_quality = newValue
		}
	}

	public var _paperSize: PaperSize?

	/**
		The default paper size to use for printing
	*/
	public var paperSize: PaperSize {
		get {
			return _paperSize ?? outputType.paperSize
		}
		set {
			_paperSize = newValue
		}
	}

	public var _grayscale: Bool?

	/**
		Whether the contents should be printed in grayscale
	*/
	public var grayscale: Bool {
		get {
			return _grayscale ?? outputType.grayscale
		}
		set {
			_grayscale = newValue
		}
	}

	private var configurationHandler: ((PrintSettings) -> Void)?

	/**
		Creates a new `PrintInfo` with default configuration
	*/
	public static func printInfo() -> PrintInfo {
		return PrintInfo()
	}

	/**
		Gtk's underlying print API exposes many additional settings not included in `PrintInfo`. By providing a handler here, you can modify these settings when setting up a print job

		- Parameter settings: The `PrintSettings` object to perform additional configuration
	*/
	public func onConfigure(_ handler: @escaping (_ settings: PrintSettings) -> Void) {
		configurationHandler = handler
	}

	/**
		Applies the configuration of this `PrintInfo` to `settings`
	*/
	internal func apply(to settings: PrintSettings) {
		settings.duplex = duplex.convert(for: orientation)
		settings.orientation = orientation.pageOrientation
		settings.set(paperSize: paperSize)
		settings.quality = quality
		settings.useColor = !grayscale
		configurationHandler?(settings)
	}


}

/**
	Constants for specifying a duplex mode for a print operation
*/
public enum PrintDuplex {
	/**
		Prints on a single side only
	*/
	case none
	/**
		Flips the printed content along the longer side of the page
	*/
	case longEdge
	/**
		Flips the printed content along the shorter side of the page
	*/
	case shortEdge
}

public extension PrintDuplex {

	func convert(for orientation: PrintOrientation) -> Gtk.PrintDuplex {
		switch self {
			case .none:
				return .simplex
			case .longEdge:
				switch orientation {
					case .portrait:
						return .horizontal
					case .landscape:
						return .vertical
				}
			case .shortEdge:
				switch orientation {
					case .portrait:
						return .vertical
					case .landscape:
						return .horizontal
				}
		}
	}

}

/**
	Constants for specifying an orientation for a print operation
*/
public enum PrintOrientation {
	case portrait
	case landscape
}

public extension PrintOrientation {

	var pageOrientation: PageOrientation {
		switch self {
			case .portrait:
				return .portrait
			case .landscape:
				return .landscape
		}
	}

}

/**
	Constants for specifying the content type for a print operation
*/
public enum PrintOutputType {
	/**
		Specifies that content should be printed in normal quality, and should default to duplex mode and A4 paper size.
		This is suitable for documents such as reports, articles, etc.
	*/
	case general
	/**
		Specifies that the contents should be printed in high quality, defaulting to duplex mode and A4 paper size.
		This is suitable for articles that exhibit high quality images, such as might be found in a nature magazine.
	*/
	case generalHD
	/**
		Specifies that the contents should be printed in high quality, defaulting to simplex mode and A6 paper size. This is suitable for printing photos
	*/
	case photo
	/**
		Specifies the the contents should be printed in high quality, defaulting to duplex mode and A4 paper size. Grayscale mode is the default.
	*/
	case photoGrayscale

}

public extension PrintOutputType {

	public var quality: PrintQuality {
		switch self {
			case .general:
				return PrintQuality.normal
			case .generalHD:
				return PrintQuality.high
			case .photo:
				return PrintQuality.high
			case .photoGrayscale:
				return PrintQuality.high
		}
	}

	public var duplex: PrintDuplex {
		switch self {
			case .general:
				return .longEdge
			case .generalHD:
				return .longEdge
			case .photo:
				return .none
			case .photoGrayscale:
				return .longEdge
		}
	}

	public var paperSize: PaperSize {
		switch self {
			case .photo:
				return .A6
			default:
				return .A4
		}
	}

	public var grayscale: Bool {
		switch self {
			case .photoGrayscale:
				return true
			default:
				return false
		}
	}

}
