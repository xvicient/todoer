import SwiftUI

@testable import Todoer

final class TestCoordinator: CoordinatorApi {
    
    // MARK: - CoordinatorApi
    
    func loggOut() {
        isLoggOutCalled = true
    }
    
    func loggIn() {
        isLoggInCalled = true
    }
    
    func push(_ page: Todoer.Page) {}
    
    func present(sheet: Todoer.Sheet) {}
    
    func present(fullScreenCover: Todoer.FullScreenCover) {}
    
    func pop() {}
    
    func popToRoot() {}
    
    func dismissSheet() {
        isDismissSheetCalled = true
    }
    
    // MARK: - TestCoordinator
    
    var isLoggOutCalled = false
    
    var isLoggInCalled = false
    
    var isDismissSheetCalled = false
}
