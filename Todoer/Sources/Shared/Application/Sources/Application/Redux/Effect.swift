import Combine
import SwiftUI

public enum Effect<Action> {
	case none
	case publish(AnyPublisher<Action, Never>)
    case task((@MainActor @escaping (Action) -> Void) async -> Void)
}
