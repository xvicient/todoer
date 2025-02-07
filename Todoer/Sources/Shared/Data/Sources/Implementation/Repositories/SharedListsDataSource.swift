import Combine
import Common

public protocol SharedListsDataSourceApi: AnyObject {
    var sharedLists: [String] { get set }
}

public class SharedListsDataSource: SharedListsDataSourceApi {
    @AppSetting(key: "sharedLists", defaultValue: [""])
    public var sharedLists: [String]

    public init() {}
}
