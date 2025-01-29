import UIKit
import SwiftUI
import SwiftData
import Application
import FirebaseCore
import FirebaseAuth
import Data

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        view.backgroundColor = .clear
        
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return
        }
        
        struct Dependencies: Share.Dependencies {
            let items: [NSExtensionItem]
            let context: NSExtensionContext?
        }
        
        let shareScreen = Share.Builder.makeShare(
            dependencies: Dependencies(
                items: inputItems,
                context: extensionContext
            )
        )
        
        let hostincViewController = UIHostingController(rootView: shareScreen)
        hostincViewController.view.frame = view.frame
        hostincViewController.view.backgroundColor = .clear
        view.addSubview(hostincViewController.view)
    }
}
