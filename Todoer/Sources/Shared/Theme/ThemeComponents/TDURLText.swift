import SwiftUI

public struct TDURLText: View {
    let text: String
    
    public var body: some View {
        highlightURL(in: text)
    }
    
    func highlightURL(in text: String) -> Text {
        var highlightedText = Text("")
        
        text.split(separator: " ").forEach {
            if $0.hasPrefix("www.") || $0.hasPrefix("http://") || $0.hasPrefix("https://") {
                highlightedText = highlightedText + Text(" ") + Text(.init("\($0)"))
                    .underline()
            } else {
                highlightedText = highlightedText + Text(" \($0)")
            }
        }
        
        return highlightedText
    }
}
