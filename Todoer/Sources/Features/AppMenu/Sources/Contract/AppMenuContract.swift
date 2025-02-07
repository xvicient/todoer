import CoordinatorContract
import SwiftUI

public struct AppMenu {}

public protocol AppMenuDependencies {
    /// The coordinator API used for navigation and flow control
    var coordinator: CoordinatorApi { get }
}
