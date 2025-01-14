import CoordinatorContract
import Entities

public protocol ShareListScreenDependencies {
    var coordinator: CoordinatorApi { get }
    var list: UserList { get }
}
