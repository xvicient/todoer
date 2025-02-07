import SwiftUI

/// Extension providing keyboard dismissal functionality to SwiftUI View
public extension View {
    /// Dismisses the keyboard by resigning the first responder status
    /// This method uses UIKit's responder chain to dismiss the keyboard from any view
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
