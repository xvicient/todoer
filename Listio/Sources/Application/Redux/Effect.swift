import Combine
import SwiftUI

public enum Effect<Action> {
    case none
    case publish(AnyPublisher<Action, Never>)
    case task(Task<Action, Error>?)
}
