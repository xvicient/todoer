//
//  TDListRowModifier.swift
//  Todoer
//
//  Created by xvicient on 20/2/24.
//

import SwiftUI

struct TDListRowModifier: ViewModifier {
    var onChangeOf: Bool
    var index: Int
    var scrollView: ScrollViewProxy
    
    func body(content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scrollContentBackground(.hidden)
            .onChange(of: onChangeOf, {
                withAnimation {
                    scrollView.scrollTo(index - 1,
                                        anchor: .bottom)
                }
            })
    }
}
