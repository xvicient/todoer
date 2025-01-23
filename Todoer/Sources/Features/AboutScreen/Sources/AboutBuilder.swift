import SwiftUI

public struct About {
    
    /// Builder for creating and configuring About screen instances
    public struct Builder {
        
        /// Creates a new About screen instance
        /// - Parameters:
        /// - Returns: Configured About screen view
		@MainActor
        public static func makeAbout() -> some View {
			AboutScreen()
		}
	}
}
