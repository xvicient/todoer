import Combine
import SwiftUI

public enum Effect<Action> {
	case none
	case publish(AnyPublisher<Action, Never>)
	case task(@Sendable ((Action) async -> Void) async -> Void)
}
