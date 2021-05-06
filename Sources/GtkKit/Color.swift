//
//  Color.swift
//  GtkMvc
//
//  Created by Jane Fraser on 23/10/20.
//

import Foundation
import Gdk
import Cairo

public class Color {
	
	public var red: Double;
	
	public var green: Double;
	
	public var blue: Double;
	
	public var alpha: Double
	
	public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
		self.red = red;
		self.green = green;
		self.blue = blue;
		self.alpha = alpha;
	}
	
	public init(from rgba: RGBA) {
		self.red = rgba.red
		self.green = rgba.green
		self.blue = rgba.blue
		self.alpha = rgba.alpha
	}

	public func set(on context: ContextProtocol) {
		context.setSource(red: red, green: green, blue: blue, alpha: alpha);
	}
	
}

public extension Color {

	static let systemBlue1 = Color(red: 153 / 255, green: 193 / 255, blue: 241 / 255)
	static let systemBlue2 = Color(red: 98 / 255, green: 160 / 255, blue: 234 / 255)
	static let systemBlue3 = Color(red: 53 / 255, green: 132 / 255, blue: 228 / 225)
	static let systemBlue4 = Color(red: 28 / 255, green: 113 / 255, blue: 216 / 255)
	static let systemBlue5 = Color(red: 26 / 255, green: 95 / 255, blue: 180 / 255)

	static let systemGreen1 = Color(red: 143 / 255, green: 240 / 255, blue: 164 / 255)
	static let systemGreen2 = Color(red: 87 / 255, green: 227 / 255, blue: 137 / 255)
	static let systemGreen3 = Color(red: 51 / 255, green: 209 / 255, blue: 122 / 255)
	static let systemGreen4 = Color(red: 46 / 255, green: 194 / 255, blue: 126 / 255)
	static let systemGreen5 = Color(red: 38 / 255, green: 162 / 255, blue: 105 / 255)

	static let systemYellow1 = Color(red: 249 / 255, green: 240 / 255, blue: 107 / 255)
	static let systemYellow2 = Color(red: 248 / 255, green: 228 / 255, blue: 92 / 255)
	static let systemYellow3 = Color(red: 246 / 255, green: 211 / 255, blue: 45 / 255)
	static let systemYellow4 = Color(red: 245 / 255, green: 194 / 255, blue: 17 / 255)
	static let systemYellow5 = Color(red: 229 / 255, green: 165 / 255, blue: 10 / 255)

	static let systemOrange1 = Color(red: 255 / 255, green: 190 / 255, blue: 111 / 255)
	static let systemOrange2 = Color(red: 255, green: 163 / 255, blue: 72 / 255)
	static let systemOrange3 = Color(red: 255 / 255, green: 120 / 255, blue: 0 / 255)
	static let systemOrange4 = Color(red: 230 / 255, green: 97 / 255, blue: 0 / 255)
	static let systemOrange5 = Color(red: 198 / 255, green: 70 / 255, blue: 0 / 255)

	static let systemRed1 = Color(red: 246 / 255, green: 97 / 255, blue: 81 / 255)
	static let systemRed2 = Color(red: 237 / 255, green: 51 / 255, blue: 59 / 255)
	static let systemRed3 = Color(red: 224 / 255, green: 27 / 255, blue: 36 / 255)
	static let systemRed4 = Color(red: 192 / 255, green: 28 / 255, blue: 40 / 255)
	static let systemRed5 = Color(red: 165 / 255, green: 29 / 255, blue: 45 / 255)

	static let systemPurple1 = Color(red: 220 / 255, green: 138 / 255, blue: 221 / 255)
	static let systemPurple2 = Color(red: 192 / 255, green: 97 / 255, blue: 203 / 255)
	static let systemPurple3 = Color(red: 145 / 255, green: 65 / 255, blue: 172 / 255)
	static let systemPurple4 = Color(red: 129 / 255, green: 61 / 255, blue: 156 / 255)
	static let systemPurple5 = Color(red: 97 / 255, green: 53 / 255, blue: 131 / 255)

	static let systemBrown1 = Color(red: 205 / 255, green: 171 / 255, blue: 143 / 255)
	static let systemBrown2 = Color(red: 181 / 255, green: 131 / 255, blue: 90 / 255)
	static let systemBrown3 = Color(red: 152 / 255, green: 106 / 255, blue: 68 / 255)
	static let systemBrown4 = Color(red: 134 / 255, green: 94 / 255, blue: 60 / 255)
	static let systemBrown5 = Color(red: 99 / 255, green: 69 / 255, blue: 44 / 255)

	static let systemNeutral1 = Color(red: 246 / 255, green: 245 / 255, blue: 244 / 255)
	static let systemNeutral2 = Color(red: 222 / 255, green: 221 / 255, blue: 218 / 255)
	static let systemNeutral3 = Color(red: 192 / 255, green: 191 / 255, blue: 188 / 255)
	static let systemNeutral4 = Color(red: 154 / 255, green: 153 / 255, blue: 150 / 255)
	static let systemNeutral5 = Color(red: 119 / 255, green: 118 / 255, blue: 123 / 255)
	static let systemNeutral6 = Color(red: 94 / 255, green: 92 / 255, blue: 100 / 255)
	static let systemNeutral7 = Color(red: 61 / 255, green: 56 / 255, blue: 70 / 255)
	static let systemNeutral8 = Color(red: 36 / 255, green: 31 / 255, blue: 49 / 255)

}
