//
//  View+Extensions.swift
//  SwiftUIChallenge
//
//  Created by Alexandra Biskulova on 20.02.2024.
//

import Foundation
import SwiftUI

struct BlueButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .tint(.white)
            .foregroundColor(.blue)
            .buttonStyle(.borderedProminent)
//            .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .stroke(lineWidth: 1)
//                        )
    }
}

struct CheckmarkModifier: ViewModifier {
    var checked: Bool = false
    func body(content: Content) -> some View {
        Group {
            if checked {
                ZStack(alignment: .trailing) {
                    content
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                        .shadow(radius: 1)
                }
            } else {
                content
            }
        }
    }
}

extension View {
    func blueButtonStyle() -> some View {
        modifier(BlueButtonStyleModifier())
    }
    
    func checkmark(for isChecked: Bool) -> some View {
        modifier(CheckmarkModifier(checked: isChecked))
    }
}
