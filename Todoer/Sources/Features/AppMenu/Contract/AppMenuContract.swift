import SwiftUI
import CoordinatorContract

public struct AppMenu {
    public typealias MakeAppMenuView = () -> AnyView
}

public protocol AppMenuDependencies {
    var coordinator: CoordinatorApi { get }
}
