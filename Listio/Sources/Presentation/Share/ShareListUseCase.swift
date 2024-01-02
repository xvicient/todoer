import Foundation
import Combine

protocol ShareListUseCaseApi {
    func fetchUsers(
        uids: [String]
    ) async -> Result<[User], Error>
}

extension ShareList {
    struct UseCase: ShareListUseCaseApi {
        private enum Errors: Error {
            case unexpectedError
        }
        
        private let usersRepository: UsersRepositoryApi
        
        init(usersRepository: UsersRepositoryApi = UsersRepository()) {
            self.usersRepository = usersRepository
        }
        
        func fetchUsers(
            uids: [String]
        ) async -> Result<[User], Error> {
            do {
                let result = try await usersRepository.fetchUsers(uids: uids)
                return .success(result)
            } catch {
                return .failure(error)
            }
        }
    }
}
