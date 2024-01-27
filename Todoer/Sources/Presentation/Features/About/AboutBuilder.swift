import SwiftUI

struct About {
    struct Builder {
        @MainActor
        static func makeAbout(
        ) -> AboutView {
            AboutView()
        }
    }
}
