import SwiftUI
import CoordinatorContract

public struct AppMenu {}

public protocol AppMenuDependencies {
    /// The coordinator API used for navigation and flow control
    var coordinator: CoordinatorApi { get }
}
