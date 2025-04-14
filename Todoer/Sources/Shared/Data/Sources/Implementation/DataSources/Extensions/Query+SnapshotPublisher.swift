import Combine
import FirebaseFirestore

public extension Query {
    /// Creates a Combine publisher that provides real-time Firestore updates
    /// - Returns: An `AnyPublisher<QuerySnapshot, Error>` that provides updates through a snapshot listener
    ///   - Automatically manages listener lifecycle
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
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

public extension QuerySnapshot {
    /// Conditionally skips processing this snapshot based on an external stop flag.
    /// - Parameter isStopped: An `inout` boolean flag indicating whether the publisher should skip this snapshot.
    /// - Returns: The current `QuerySnapshot` instance if not stopped, or `nil` if skipped.
    func skip(if isStopped: inout Bool) -> Self? {
        if isStopped {
            isStopped = false
            return nil
        }
        return self
    }
}

