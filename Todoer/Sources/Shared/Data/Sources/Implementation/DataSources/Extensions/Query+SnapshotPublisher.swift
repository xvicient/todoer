import Combine
import FirebaseFirestore

/// A class to manage skip state for snapshot listeners
public final class SnapshotState {
    public var isStopped: Bool
    
    public init(isStopped: Bool = false) {
        self.isStopped = isStopped
    }
}

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
    
    /// Creates a Combine publisher that provides real-time Firestore updates with skip capability
    /// - Parameter SnapshotState: A reference to the state manager that controls skipping behavior
    /// - Returns: An `AnyPublisher<QuerySnapshot, Error>` that provides updates through a snapshot listener,
    ///   with the ability to skip snapshots based on the stateManager
    func snapshotPublisher(skipWith state: SnapshotState) -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()
        
        let listener = self.addSnapshotListener { snapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
            } else if let snapshot = snapshot {
                if state.isStopped {
                    state.isStopped = false
                } else {
                    subject.send(snapshot)
                }
            }
        }

        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}

private extension QuerySnapshot {
    /// Conditionally skips processing this snapshot based on a state manager.
    /// - Parameter stateManager: The state manager that controls skipping behavior
    /// - Returns: The current `QuerySnapshot` instance if not stopped, or `nil` if skipped.
    func skip(with stateManager: SnapshotState) -> Self? {
        if stateManager.isStopped {
            stateManager.isStopped = false
            return nil
        }
        return self
    }
}
