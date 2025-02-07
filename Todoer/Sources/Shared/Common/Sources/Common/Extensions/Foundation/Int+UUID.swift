import Foundation

/// Extension providing UUID conversion functionality to Int
public extension Int {
    /// Converts the integer to a UUID by using its bytes
    /// The integer's bytes are copied into the UUID's byte array in little-endian order
    /// - Returns: A UUID generated from the integer's bytes
    var uuid: UUID {
        var uuidBytes = [UInt8](repeating: 0, count: 16)
        
        // Copy the lower bits of the Int into the UUID's bytes
        withUnsafeBytes(of: self.littleEndian) { bytes in
            for (index, byte) in bytes.enumerated() where index < 16 {
                uuidBytes[index] = byte
            }
        }
        
        return UUID(uuid: uuidBytes.withUnsafeBytes { $0.load(as: uuid_t.self) })
    }
}
