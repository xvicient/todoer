import Foundation
import SwiftUI

public protocol AppAlertState<Action>: Equatable {
    associatedtype Action: Sendable
    var alertBinding: Binding<AppAlert<Action>?> { get }
}

public struct AppAlert<Action: Sendable>: Equatable, Sendable, Identifiable {
    public var id: String {
        title + message + primaryAction.1 + (secondaryAction?.1 ?? "")
    }
    let title: String
    let message: String
    let primaryAction: (Action, String)
    let secondaryAction: (Action, String)?
    
    public init(
        title: String = "",
        message: String = "",
        primaryAction: (Action, String),
        secondaryAction: (Action, String)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    public func alert(
        send: @escaping (Action) -> Void
    ) -> Alert {
        guard let secondaryAction = secondaryAction else {
            return error(send)
        }
        
        return Alert(
            title: Text(title),
            message: Text(message),
            primaryButton: .destructive(Text(primaryAction.1)) {
                send(primaryAction.0)
            },
            secondaryButton: .default(Text(secondaryAction.1)) {
                send(secondaryAction.0)
            }
        )
    }
    
    private func error(
        _ send: @escaping (Action) -> Void
    ) -> Alert {
        Alert(
            title: Text(title),
            message: Text(message),
            dismissButton: .default(Text(primaryAction.1)) {
                send(primaryAction.0)
            }
        )
    }

    public static func == (lhs: AppAlert<Action>, rhs: AppAlert<Action>) -> Bool {
        lhs.id == rhs.id
    }
}
