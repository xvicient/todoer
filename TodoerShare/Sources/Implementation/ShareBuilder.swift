import Foundation
import SwiftUI
import xRedux

public struct Share {
    public protocol Dependencies {
        var items: [NSExtensionItem] { get }
        var context: NSExtensionContext? { get }
    }
    
    @MainActor
    public struct Builder {
        
        public static func makeShare(
            dependencies: Dependencies
        ) -> some View {
            let reducer = Reducer(
                dependencies: dependencies,
                useCase: UseCase()
            )
            let store = Store(initialState: .init(), reducer: reducer)
            return ShareScreen(
                store: store
            )
        }
        
    }
}
