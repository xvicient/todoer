import SwiftUI

public enum TDSlideTransition {
    case forward
    case backward
    
    var transition: AnyTransition {
        switch self {
        case .forward:
                .asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                )
        case .backward:
                .asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                )
        }
    }
}
