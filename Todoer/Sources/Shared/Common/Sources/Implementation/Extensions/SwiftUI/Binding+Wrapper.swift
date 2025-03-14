import SwiftUI

@MainActor
public extension Binding {
    init(_ value: Binding<Value>) {
        self.init(
            get: { value.wrappedValue },
            set: { _ in }
        )
    }
}
