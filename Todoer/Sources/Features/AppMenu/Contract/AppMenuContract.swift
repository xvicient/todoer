import SwiftUI
import CoordinatorContract

public struct AppMenu {}

public protocol AppMenuDependencies {
    var coordinator: CoordinatorApi { get }
}
