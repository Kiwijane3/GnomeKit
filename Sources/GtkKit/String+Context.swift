import Foundation
import Cairo

public extension String {

	var size: CGSize {
		let surface = imageSurfaceCreate(format: .init(0), width: 0, height: 0)
		let context = Context(surface: surface)
		let extents = context.textExtents(self)
		return CGSize(width: extents.width, height: extents.height)
	}

	func draw(at origin: CGPoint, in context: ContextProtocol) {
		context.save()
		context.newPath()
		context.moveTo(Double(origin.x), Double(origin.y))
		context.showText(self)
		context.restore()
	}

}
