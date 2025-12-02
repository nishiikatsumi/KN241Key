//
//  KeyButton.swift
//  Test20251201
//
//  Created by 西井勝巳 on 2025/12/01.
//

import SwiftUI

struct KeyButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.primary)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
                .cornerRadius(8)
        }
    }
}

#Preview {
    KeyButton(title: "あ", action: {})
}
