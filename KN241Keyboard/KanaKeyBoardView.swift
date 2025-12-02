//
//  KanaKeyBoardView.swift
//  Test20251201
//
//  Created by 西井勝巳 on 2025/12/01.
//

//
//  KanaKeyBoardView.swift
//  KN241Key
//
//  Created by 西井勝巳 on 2025/12/01.
//

import SwiftUI

private enum KeyboardLayer {
    case kana
    case numbers
    case alphabet
}

struct KanaKeyboardView: View {

    @ObservedObject var viewModel: KeyboardViewModel

    let nextKeyboardAction: () -> Void

    @State private var layer: KeyboardLayer = .kana

    // 50音
    private let kanaRows: [[String]] = [
        ["あ","か","さ","た","な","は","ま","や","ら","わ"],
        ["い","き","し","ち","に","ひ","み","","り","を"],
        ["う","く","す","つ","ぬ","ふ","む","ゆ","る","ん"],
        ["え","け","せ","て","ね","へ","め","","れ",""],
        ["お","こ","そ","と","の","ほ","も","よ","ろ",""]
    ]

    private let numberRows: [[String]] = [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["-","/","：","；","（","）","¥","＆","＠","\""],
        ["[","]","{","}","#","%","^","*","+","="]
    ]

    private let alphabetRows: [[String]] = [
        ["q","w","e","r","t","y","u","i","o","p"],
        ["a","s","d","f","g","h","j","k","l",""],
        ["z","x","c","v","b","n","m","","",""]
    ]

    private let keySpacing: CGFloat = 6
    private let rowSpacing: CGFloat = 8

    var body: some View {
        VStack(spacing: 4) {

            // 🔹 上部：読みと候補一覧
            candidateBar

            GeometryReader { geo in
                let width = geo.size.width
                let keyWidth = (width - keySpacing * 13) / 12
                let keyHeight: CGFloat = 56

                HStack(spacing: keySpacing) {

                    leftCol(keyWidth: keyWidth, keyHeight: keyHeight)

                    switch layer {
                    case .kana:
                        kanaGrid(keyWidth: keyWidth, keyHeight: keyHeight)
                    case .numbers:
                        numberGrid(keyWidth: keyWidth, keyHeight: keyHeight)
                    case .alphabet:
                        alphabetGrid(keyWidth: keyWidth, keyHeight: keyHeight)
                    }

                    rightCol(keyWidth: keyWidth, keyHeight: keyHeight)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
            }
        }
    }

    // MARK: - 候補バー

    private var candidateBar: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !viewModel.currentReading.isEmpty {
                Text(viewModel.currentReading)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.candidates) { cand in
                        Button {
                            viewModel.selectCandidate(cand)
                        } label: {
                            Text(cand.surface)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 4)
    }

    // MARK: - グリッド（かな／数字／アルファベット）

    private func kanaGrid(keyWidth: CGFloat, keyHeight: CGFloat) -> some View {
        VStack(spacing: rowSpacing) {
            ForEach(0..<kanaRows.count, id: \.self) { row in
                HStack(spacing: keySpacing) {
                    ForEach(0..<kanaRows[row].count, id: \.self) { col in
                        let char = kanaRows[row][col]
                        if char.isEmpty {
                            Color.clear.frame(width: keyWidth, height: keyHeight)
                        } else {
                            KeyButton(title: char) {
                                viewModel.inputKana(char)
                            }
                            .frame(width: keyWidth, height: keyHeight)
                        }
                    }
                }
            }
        }
    }

    private func numberGrid(keyWidth: CGFloat, keyHeight: CGFloat) -> some View {
        VStack(spacing: rowSpacing) {
            ForEach(numberRows.indices, id: \.self) { row in
                HStack(spacing: keySpacing) {
                    ForEach(numberRows[row].indices, id: \.self) { col in
                        let char = numberRows[row][col]
                        KeyButton(title: char) {
                            viewModel.commitRaw()
                            viewModel.textDocumentProxy?.insertText(char)
                        }
                        .frame(width: keyWidth, height: keyHeight)
                    }
                }
            }
        }
    }

    private func alphabetGrid(keyWidth: CGFloat, keyHeight: CGFloat) -> some View {
        VStack(spacing: rowSpacing) {
            ForEach(alphabetRows.indices, id: \.self) { row in
                HStack(spacing: keySpacing) {
                    ForEach(alphabetRows[row].indices, id: \.self) { col in
                        let char = alphabetRows[row][col]
                        if char.isEmpty {
                            Color.clear.frame(width: keyWidth, height: keyHeight)
                        } else {
                            KeyButton(title: char) {
                                viewModel.commitRaw()
                                viewModel.textDocumentProxy?.insertText(char)
                            }
                            .frame(width: keyWidth, height: keyHeight)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 左側キー（あいう / ABC /123 / 地球儀）

    private func leftCol(keyWidth: CGFloat, keyHeight: CGFloat) -> some View {
        VStack(spacing: rowSpacing) {
            KeyButton(title: "あいう") { layer = .kana }
                .frame(width: keyWidth, height: keyHeight)

            KeyButton(title: "ABC") {
                viewModel.commitRaw()
                layer = .alphabet
            }
            .frame(width: keyWidth, height: keyHeight)

            KeyButton(title: "123") {
                viewModel.commitRaw()
                layer = .numbers
            }
            .frame(width: keyWidth, height: keyHeight)

            Color.clear.frame(width: keyWidth, height: keyHeight)

            KeyButton(title: "🌐") { nextKeyboardAction() }
                .frame(width: keyWidth, height: keyHeight)
        }
    }

    // MARK: - 右側キー（⌫ 空白 ⏎）

    private func rightCol(keyWidth: CGFloat, keyHeight: CGFloat) -> some View {
        VStack(spacing: rowSpacing) {

            KeyButton(title: "⌫") {
                viewModel.deleteBackward()
            }
            .frame(width: keyWidth, height: keyHeight)

            KeyButton(title: "空白") {
                viewModel.commitRaw()
                viewModel.textDocumentProxy?.insertText(" ")
            }
            .frame(width: keyWidth, height: keyHeight)

            KeyButton(title: "⏎") {
                viewModel.commitRaw()
                viewModel.textDocumentProxy?.insertText("\n")
            }
            .frame(width: keyWidth, height: keyHeight)
        }
    }
}


