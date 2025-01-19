import Combine
import Data
import Application

protocol MenuUseCaseApi {
    func getPhotoUrl() async -> ActionResult<String>
    
    func signOut() -> ActionResult<EquatableVoid>

    func deleteAccount() async -> ActionResult<EquatableVoid>
}

extension AppMenu {
    
	struct UseCase: MenuUseCaseApi {

        private let listsRepository: ListsRepositoryApi
        private let usersRepository: UsersRepositoryApi
        private let authenticationService: AuthenticationService

        init(
            listsRepository: ListsRepositoryApi = ListsRepository(),
            usersRepository: UsersRepositoryApi = UsersRepository(),
            authenticationService: AuthenticationService = AuthenticationService()
        ) {
            self.listsRepository = listsRepository
            self.usersRepository = usersRepository
            self.authenticationService = authenticationService
        }

		func getPhotoUrl() async -> ActionResult<String> {
			do {
				let photoUrl = try await usersRepository.getSelfUser()?.photoUrl
				return .success(photoUrl ?? "")
			}
			catch {
				return .failure(error)
			}
		}
        
        func signOut() -> ActionResult<EquatableVoid> {
            do {
                try authenticationService.signOut()
                usersRepository.setUid("")
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
        
        func deleteAccount() async -> ActionResult<EquatableVoid> {
            do {
                try await usersRepository.deleteUser()
                try await listsRepository.deleteSelfUserLists()
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
	}
}
