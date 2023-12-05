import Foundation

extension DispatchGroup {
    func execute(
        _ blocks: (() -> Void) -> Void...,
        onComplete:  @escaping () -> Void)
    {
        DispatchQueue.global(qos: .default).sync { [weak self] in
            blocks.forEach { [weak self] block in
                self?.enter()
                block { [weak self] in
                    self?.leave()
                }
            }
            
            self?.notify(queue: .main) {
                onComplete()
            }
        }
    }
}
