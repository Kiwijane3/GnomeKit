//
//  BezierPath.swift
//  GtkMvc
//
//  Created by Jane Fraser on 22/10/20.
//

import Foundation
import CCairo
import Cairo



public enum LineCap {
	case butt
	case round
	case square
}

extension LineCap {
	
	internal var cairo: cairo_line_cap_t {
		switch self {
		case .butt:
			return .butt
		case .round:
			return .round;
		case .square:
			return .square;
		}
	}
	
}

public enum LineJoin {
	case miter
	case round
	case bevel
}

extension LineJoin {

	internal var cairo: cairo_line_join_t {
		switch self {
		case .miter:
			return .miter
		case .round:
			return .round
		case .bevel:
			return .bevel
		}
	}

}

let evenOddFillRule = FillRule.init(1);
let windingFillRule = FillRule.init(0);

public class BezierPath {
	
	// This empty shared graphical context is used by CGPoint to calculate path extents and contains.
	internal static var calcContext: ContextProtocol = Context(surface: imageSurfaceCreate(format: .init(0), width: 0, height: 0));
	
	enum Operation {
		case move(target: CGPoint)
		case line(target: CGPoint)
		case arc(center: CGPoint, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool)
		case curve(target: CGPoint, controlA: CGPoint, controlB: CGPoint)
		case quadCurve(target: CGPoint, control: CGPoint)
		case close
	}
	
	internal var operations: [Operation] = [];

	/**
		The width used for drawing lines
	*/
	public var lineWidth: Double = 1.0;
	
	/**
		The style used for drawing the ends of lines
	*/
	public var lineCapStyle: LineCap = .butt;
	
	/**
		The style used for joining lines
	*/
	public var lineJoinStyle: LineJoin = .bevel

	/**
		Determines whether lines should be joined with a bevel or a miter. The graphics library divides the length of the miter by the line width. If the result is greater than the miter limit, the join is drawn as a bevel.
	*/
	public var miterLimit: Double = 10;
	
	/**
		Sets the fill rule to be used determine whether regions are inside or outside complex paths
	*/
	public var usesEvenOddFillRule: Bool = false;
	
	/**
		Sets the pattern of dashes to be used when drawing.
	*/
	public var dashPattern: [Double]?;
	
	/**
		Determines the starting point of the dash pattern
	*/
	public var dashPhase: Double = 0;

	public init() {

	}
	
	/**
		Moves the current point to `target`

		- Parameter target: The position to move to
	*/
	public func move(to target: CGPoint) {
		operations.append(.move(target: target))
	}
	
	/**
		Adds a line from the current point to `target`
	*/
	public func addLine(to target: CGPoint) {
		operations.append(.line(target: target));
	}
	
	/**
		Adds an arc

		- Parameter center: The center of the arc

		- Parameter radius: The radius of the arc

		- Parameter startAngle: The angle at which the arc starts

		- Parameter endAngle: The angle at which the arc ends

		- Parameter clockwise: Whether the arc should be drawn clockwise
	*/
	public func addArc(withCenter center: CGPoint, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool) {
		operations.append(.arc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise));
	}
	
	/**
		Adds a bezier curve, which starts at the current point

		- Parameter target: The end point of the bezier curve

		- Parameter controlA: The first control point of the bezier curve

		- Parameter controlB: The second control point of the bezier curve
	*/
	public func addCurve(to target: CGPoint, controlA: CGPoint, controlB: CGPoint) {
		operations.append(.curve(target: target, controlA: controlA, controlB: controlB))
	}
	
	/**
		Adds a quadratic bezier curve, which starts at the current point

		- Parameter target: The end point of the bezier curve

		- Parameter control: The control point of the bezier curve
	*/
	public func addQuadCurve(to target: CGPoint, control: CGPoint) {
		operations.append(.quadCurve(target: target, control: control))
	}
	
	/**
		Adds a rectangle corresponding to `rect` to the current path
	*/
	public func addRect(_ rect: CGRect) {
		operations.append(.move(target: rect.origin))
		operations.append(.line(target: CGPoint(x: rect.maxX, y: rect.minY)))
		operations.append(.line(target: CGPoint(x: rect.maxX, y: rect.maxY)))
		operations.append(.line(target: CGPoint(x: rect.minX, y: rect.maxY)))
		operations.append(.close)
	}

	/**
		Closes the current path: i.e., adds a line connecting the start point and end point
	*/
	public func close() {
		operations.append(.close)
	}

	/**
		Sets the dash pattern for drawing line

		- Parameter pattern: The dash pattern

		- Parameter phase: The offset to start the pattern at
	*/
	public func setLineDash(_ pattern: [Double]?, phase: Double) {
		self.dashPattern = pattern;
		self.dashPhase = phase;
	}
	
	/**
		Fills the current path onto `context`
	*/
	public func fill(on context: ContextProtocol) {
		// Save and restore the context so we don't modify any existing paths.
		context.save();
		writePath(to: context);
		context.fill();
		context.restore();
	}
	
	/**
		Strokes the current path onto `context`
	*/
	public func stroke(on context: ContextProtocol) {
		context.save();
		writePath(to: context);
		context.stroke();
		context.restore();
	}
	
	/**
		Returns whether `point` falls within the area painted by this path
	*/
	public func contains(_ point: CGPoint) -> Bool {
		return fillContains(point) || strokeContains(point)
	}

	/**
		Returns whether `point` falls within the area painted by filling this path
	*/
	public func fillContains(_ point: CGPoint) -> Bool {
		let surface = imageSurfaceCreate(format: .init(0), width: 0, height: 0)
		let context = Context(surface: surface)
		writePath(to: context)
		return context.isInFill(Double(point.x), Double(point.y))
	}
	
	/**
		Returns whether `point` falls within the area painted by stroking this path
	*/
	public func strokeContains(_ point: CGPoint) -> Bool {
		let surface = imageSurfaceCreate(format: .init(0), width: 0, height: 0)
		let context = Context(surface: surface)
		writePath(to: context);
		return context.isInStroke(Double(point.x), Double(point.y))
	}
	
	// Writes this Path's operations onto the context.
	internal func writePath(to context: ContextProtocol) {
		context.lineWidth = lineWidth;
		context.lineCap = lineCapStyle.cairo
		context.lineJoin = lineJoinStyle.cairo
		context.miterLimit = miterLimit;
		context.fillRule = usesEvenOddFillRule ? evenOddFillRule : windingFillRule;
		if let dashPattern = dashPattern {
			context.setDash(dashPattern, offset: dashPhase);
		} else {
			cairo_set_dash(context.context_ptr, [], 0, 0);
		}
		context.newPath();
		for operation in operations {
			switch operation {
			case .move(let target):
				context.moveTo(Double(target.x), Double(target.y));
			case .line(let target):
				context.lineTo(Double(target.x), Double(target.y));
			case .arc(let center, let radius, let startAngle, let endAngle, let clockwise):
				if clockwise {
					context.arc(xc: Double(center.x), yc: Double(center.y), radius: radius, angle1: startAngle, angle2: endAngle);
				} else {
					context.arcNegative(xc: Double(center.x), yc: Double(center.y), radius: radius, angle1: startAngle, angle2: endAngle);
				}
			case .quadCurve(let target, let control):
				context.curveTo(x1: Double(control.x), y1: Double(control.y), x2: Double(control.x), y2: Double(control.y), x3: Double(target.x), y3: Double(target.y));
			case .curve(let target, let controlA, let controlB):
				context.curveTo(x1: Double(controlA.x), y1: Double(controlA.y), x2: Double(controlB.x), y2: Double(controlB.y), x3: Double(target.x), y3: Double(target.y));
			case .close:
				context.closePath();
			}
		}
	}

}
