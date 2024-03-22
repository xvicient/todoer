//
//  TDListRowModifier.swift
//  Todoer
//
//  Created by xvicient on 20/2/24.
//

import SwiftUI

struct TDListRowModifier: ViewModifier {
	var onChangeOf: Bool
	var count: Int
	var scrollView: ScrollViewProxy

	func body(content: Content) -> some View {
		content
			.scrollIndicators(.hidden)
			.scrollBounceBehavior(.basedOnSize)
			.scrollContentBackground(.hidden)
			.onChange(
				of: onChangeOf,
				{
					withAnimation {
						scrollView.scrollTo(
							count - 1,
							anchor: .bottom
						)
					}
				}
			)
	}
}

extension View {
	func listRowStyle(
		onChangeOf: Bool,
		count: Int,
		scrollView: ScrollViewProxy
	) -> some View {
		modifier(
			TDListRowModifier(
				onChangeOf: onChangeOf,
				count: count,
				scrollView: scrollView
			)
		)
	}
}
