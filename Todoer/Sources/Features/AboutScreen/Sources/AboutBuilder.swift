import SwiftUI

/// Namespace for about screen-related components
public struct About {
    /// Builder for creating and configuring About screen instances
    public struct Builder {
        /// Creates a new About screen instance
        /// - Parameters:
        ///   - coordinator: Coordinator for navigation
        /// - Returns: Configured About screen view
        @MainActor
        public static func makeAbout() -> some View {
            AboutScreen()
        }
    }
}
