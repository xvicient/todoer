import FirebaseFirestore
import Combine

public extension Query {
    func snapshotPublisher() -> AnyPublisher<QuerySnapshot, Error> {
        let subject = PassthroughSubject<QuerySnapshot, Error>()

        getDocuments(source: .server) { snapshot, error in /// It forces collections to refresh after a heavy batch operation to avoid Firestore internal propagation lag
            snapshot.map { subject.send($0) }
            error.map { subject.send(completion: .failure($0)) }

            let listener = self.addSnapshotListener { snapshot, error in
                snapshot.map { subject.send($0) }
                error.map { subject.send(completion: .failure($0)) }
            }

            _ = subject.handleEvents(receiveCancel: { listener.remove() })
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }

        return subject.eraseToAnyPublisher()
    }
}
