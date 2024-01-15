import Foundation
import Combine

protocol ShareListUseCaseApi {
    func fetchUsers(
        uids: [String]
    ) async -> Result<[User], Error>
    
    func shareList(
        shareEmail: String,
        list: List
    ) async -> Result<Void, Error>
}

extension ShareList {
    struct UseCase: ShareListUseCaseApi {
        private enum Errors: Error {
            case unexpectedError
        }
        
        private let usersRepository: UsersRepositoryApi
        private let invitationsRepository: InvitationsRepositoryApi
        
        init(usersRepository: UsersRepositoryApi = UsersRepository(),
             invitationsRepository: InvitationsRepositoryApi = InvitationsRepository()) {
            self.usersRepository = usersRepository
            self.invitationsRepository = invitationsRepository
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
        
        func shareList(
            shareEmail: String,
            list: List
        ) async -> Result<Void, Error> {
            do {
                if let selfUser = try? await usersRepository.getSelfUser(),
                   let ownerName = selfUser.displayName,
                   let ownerEmail = selfUser.email,
                   let invitedUser = try? await usersRepository.getUser(shareEmail) {
                    try await invitationsRepository.sendInvitation(ownerName: ownerName,
                                                                   ownerEmail: ownerEmail,
                                                                   listId: list.documentId,
                                                                   listName: list.name,
                                                                   invitedId: invitedUser.uuid)
                    
                    return .success(())
                } else {
                    return .failure(Errors.unexpectedError)
                }
            } catch {
                return .failure(error)
            }
        }
    }
}
