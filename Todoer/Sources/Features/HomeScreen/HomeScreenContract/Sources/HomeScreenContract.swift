import SwiftUI
import CoordinatorContract

public typealias MakeHomeScreen = (CoordinatorApi) -> any View

public protocol HomeScreenBuilder {
    var makeHomeScreen: MakeHomeScreen { get }
}
