import SwiftUI

public struct About {
    public struct Builder {
		@MainActor
        public static func makeAbout() -> some View {
			AboutScreen()
		}
	}
}
