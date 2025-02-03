public extension Task where Failure == Error {
    static func delayed(
        seconds: Double,
        operation: @escaping @Sendable () async throws -> Success
    ) {
        Task {
            let delay = UInt64(seconds * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            return try await operation()
        }
    }
}
