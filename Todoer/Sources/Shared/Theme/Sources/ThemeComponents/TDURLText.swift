import SwiftUI

public struct TDURLText: View {
    let text: String

    public var body: some View {
        highlightURL(in: text)
    }

    func highlightURL(in text: String) -> Text {
        var highlightedText = Text("")
        
        let words = text.split(separator: " ")
        for (index, word) in words.enumerated() {
            let separator = index > 0 ? " " : ""
            
            if word.hasPrefix("www.") || word.hasPrefix("http://") || word.hasPrefix("https://") {
                highlightedText = highlightedText + Text(separator) + Text(.init("\(word)")).underline()
            } else {
                highlightedText = highlightedText + Text(separator) + Text("\(word)")
            }
        }
        
        return highlightedText
    }
}
