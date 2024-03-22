import SwiftUI

extension Image {
	// MARK: - Images

	public static let launchScreen = Image("LaunchScreen")
	public static let slogan = Image("Slogan")
	public static let googleLogo = Image("GoogleLogo")

	// MARK: - Icons

	public static let multiplyCircleFill = Image(systemName: "multiply.circle.fill")
	public static let circle = Image(systemName: "circle")
	public static let largecircleFillCircle = Image(systemName: "largecircle.fill.circle")
	public static let xmark = Image(systemName: "xmark")
	public static let squareAndArrowUp = Image(systemName: "square.and.arrow.up")
	public static let plusCircleFill = Image(systemName: "plus.circle.fill")
	public static let personCropCircle = Image(systemName: "person.crop.circle")
	public static let trash = Image(systemName: "trash")
	public static let squareAndPencil = Image(systemName: "square.and.pencil")
	public static let ellipsis = Image(systemName: "ellipsis")
}

extension Image {
	fileprivate init(_ name: String) {
		self.init(name, bundle: PresentationBundle.bundle)
	}
}
