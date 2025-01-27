import Foundation
import Data
import Application
import Common

protocol ShareUseCaseApi {
    func share(
        items: [NSExtensionItem]
    ) async -> ActionResult<String>
    
    func addList(
        name: String
    ) async -> ActionResult<EquatableVoid>
}

extension Share {
    
    struct UseCase: ShareUseCaseApi {
        private enum Errors: Error, LocalizedError {
            case invalidItemType
            case noDataFound
            case emptyListName
            case userNotLogged

            var errorDescription: String? {
                switch self {
                case .invalidItemType:
                    return "Invalid item type."
                case .noDataFound:
                    return "No data found."
                case .emptyListName:
                    return "UserList can't be empty."
                case .userNotLogged:
                    return "User not logged."
                }
            }
        }

        private let listsRepository: ListsRepositoryApi
        private let authenticationService: AuthenticationServiceApi
        @AppSetting(key: "sharedLists", defaultValue: [""]) private var sharedLists: [String]

        init(
            listsRepository: ListsRepositoryApi = ListsRepository(),
            authenticationService: AuthenticationServiceApi = AuthenticationService()
        ) {
            self.listsRepository = listsRepository
            self.authenticationService = authenticationService
        }
        
        func share(
            items: [NSExtensionItem]
        ) async -> ActionResult<String> {
            for item in items {
                guard let attachments = item.attachments else { continue }
                
                for attachment in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        do {
                            let url: URL = try await loadItem(from: attachment, typeIdentifier: "public.url")
                            return .success(url.absoluteString)
                        } catch {
                            return .failure(error)
                        }
                    } else if attachment.hasItemConformingToTypeIdentifier("public.plain-text") {
                        do {
                            let text: String = try await loadItem(from: attachment, typeIdentifier: "public.plain-text")
                            return .success(text)
                        } catch {
                            return .failure(error)
                        }
                    }
                }
            }
            
            return .failure(Errors.noDataFound)
        }

        private func loadItem<T>(
            from attachment: NSItemProvider,
            typeIdentifier: String
        ) async throws -> T {
            try await withCheckedThrowingContinuation { continuation in
                attachment.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (item, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let result = item as? T {
                        continuation.resume(returning: result)
                    } else {
                        continuation.resume(throwing: Errors.invalidItemType)
                    }
                }
            }
        }
        
        func addList(
            name: String
        ) async -> ActionResult<EquatableVoid> {
            guard !name.isEmpty else {
                return .failure(Errors.emptyListName)
            }
            
            guard authenticationService.isUserLogged else {
                sharedLists.append(name)
                return .failure(Errors.userNotLogged)
            }

            do {
                _ = try await listsRepository.addList(with: name)
                return .success()
            }
            catch {
                return .failure(error)
            }
        }
    }
}
