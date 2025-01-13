import SwiftUI
import CoordinatorContract

public protocol HomeDependencies {
    var coordinator: CoordinatorApi { get }
}

public struct Dependencies: HomeDependencies {
    public var coordinator: CoordinatorApi
    
    public init(
        coordinator: CoordinatorApi
    ) {
        self.coordinator = coordinator
    }
}
