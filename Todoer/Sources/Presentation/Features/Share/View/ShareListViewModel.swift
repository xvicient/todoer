import Foundation

internal extension ShareList.Reducer {
    
    // MARK: - ViewModel
    
    @MainActor
    struct ViewModel {
        var users = [User]()
    }
}
