import Combine
import FirebaseFirestore

extension Query {
    /// Creates a Combine publisher that provides real-time Firestore updates
    /// - Returns: An `AnyPublisher<QuerySnapshot, Error>` that provides updates through a snapshot listener
    ///   - Automatically manages listener lifecycle
    public func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()

        let listener = self.addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let snapshot = snapshot {
                subject.send(snapshot)
            }
        }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
