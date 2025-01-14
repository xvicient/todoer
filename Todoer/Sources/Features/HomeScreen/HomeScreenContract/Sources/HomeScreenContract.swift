import SwiftUI
import CoordinatorContract

public protocol HomeScreenDependencies {
    var coordinator: CoordinatorApi { get }
}
