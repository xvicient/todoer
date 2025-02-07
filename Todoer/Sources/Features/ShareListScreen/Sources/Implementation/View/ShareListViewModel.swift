import Entities
import Foundation

extension ShareList.Reducer {

    // MARK: - ViewModel

    @MainActor
    struct ViewModel {
        var users = [User]()
        var selfName: String?
    }
}
