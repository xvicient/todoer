import FirebaseFirestore
import Combine

public extension Query {
    /// Creates a Combine publisher that combines an initial server fetch with real-time Firestore updates
    /// - Returns: An `AnyPublisher<QuerySnapshot, Error>` that:
    ///   - First performs a forced server fetch
    ///   - Then provides real-time updates through a snapshot listener
    ///   - Automatically manages listener lifecycle
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        Deferred {
            Future<ListenerRegistration, Error> { promise in
                /// Force server fetch
                self.getDocuments(source: .server) { _, error in
                    error.map { promise(.failure($0)) }
                        ?? promise(.success(self.addSnapshotListener { _,_ in }))
                }
            }
            .flatMap { listener -> AnyPublisher<QuerySnapshot, Error> in
                let subject = PassthroughSubject<QuerySnapshot, Error>()
                listener.remove() // Remove temporary listener
                
                /// Creates persistent listener for updates
                let realListener = self.addSnapshotListener { snapshot, error in
                    snapshot.map { subject.send($0) }
                    error.map { subject.send(completion: .failure($0)) }
                }
                
                return subject
                    .handleEvents(receiveCancel: { realListener.remove() })
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}
