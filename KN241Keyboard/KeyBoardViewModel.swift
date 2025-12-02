//
//  KeyBoardViewModel.swift
//  Test20251201
//
//  Created by 西井勝巳 on 2025/12/01.
//

import SwiftUI
import UIKit
import Combine

final class KeyboardViewModel: ObservableObject {

    @Published var currentReading: String = ""
    @Published var candidates: [Candidate] = []

    private let engine: CandidateEngine
    weak var textDocumentProxy: UITextDocumentProxy?

    // 濁点・半濁点・小書きかな用のマップ
    private let dakutenMap: [Character: Character] = [
        // ひらがな
        "か": "が", "き": "ぎ", "く": "ぐ", "け": "げ", "こ": "ご",
        "さ": "ざ", "し": "じ", "す": "ず", "せ": "ぜ", "そ": "ぞ",
        "た": "だ", "ち": "ぢ", "つ": "づ", "て": "で", "と": "ど",
        "は": "ば", "ひ": "び", "ふ": "ぶ", "へ": "べ", "ほ": "ぼ",
        // カタカナ
        "カ": "ガ", "キ": "ギ", "ク": "グ", "ケ": "ゲ", "コ": "ゴ",
        "サ": "ザ", "シ": "ジ", "ス": "ズ", "セ": "ゼ", "ソ": "ゾ",
        "タ": "ダ", "チ": "ヂ", "ツ": "ヅ", "テ": "デ", "ト": "ド",
        "ハ": "バ", "ヒ": "ビ", "フ": "ブ", "ヘ": "ベ", "ホ": "ボ"
    ]

    private let handakutenMap: [Character: Character] = [
        // ひらがな
        "は": "ぱ", "ひ": "ぴ", "ふ": "ぷ", "へ": "ぺ", "ほ": "ぽ",
        // カタカナ
        "ハ": "パ", "ヒ": "ピ", "フ": "プ", "ヘ": "ペ", "ホ": "ポ"
    ]

    private let smallKanaMap: [Character: Character] = [
        // ひらがな
        "あ": "ぁ", "い": "ぃ", "う": "ぅ", "え": "ぇ", "お": "ぉ",
        "つ": "っ",
        "や": "ゃ", "ゆ": "ゅ", "よ": "ょ",
        "わ": "ゎ",
        // カタカナ
        "ア": "ァ", "イ": "ィ", "ウ": "ゥ", "エ": "ェ", "オ": "ォ",
        "ツ": "ッ",
        "ヤ": "ャ", "ユ": "ュ", "ヨ": "ョ",
        "ワ": "ヮ"
    ]

    init(textDocumentProxy: UITextDocumentProxy?, engine: CandidateEngine) {
        self.textDocumentProxy = textDocumentProxy
        self.engine = engine
    }

    // MARK: - 入力系

    func inputKana(_ char: String) {
        currentReading += char
        updateCandidates()
    }

    // 濁点「゛」キー
    func applyDakuten() {
        guard !currentReading.isEmpty else {
            // 読みが空のときに単独「゛」を入れたいならこちらで
            // textDocumentProxy?.insertText("゛")
            return
        }
        let last = currentReading.removeLast()
        if let converted = dakutenMap[last] {
            currentReading.append(converted)
        } else {
            // 変換できない場合は元に戻す
            currentReading.append(last)
        }
        updateCandidates()
    }

    // 半濁点「゜」キー
    func applyHandakuten() {
        guard !currentReading.isEmpty else {
            // textDocumentProxy?.insertText("゜")
            return
        }
        let last = currentReading.removeLast()
        if let converted = handakutenMap[last] {
            currentReading.append(converted)
        } else {
            currentReading.append(last)
        }
        updateCandidates()
    }

    // 「小」キー（小書きかな）
    func applySmallKana() {
        guard !currentReading.isEmpty else { return }

        let last = currentReading.removeLast()
        if let converted = smallKanaMap[last] {
            currentReading.append(converted)
        } else {
            currentReading.append(last)
        }
        updateCandidates()
    }

    // MARK: - 変換・確定
    // 読み → 候補取得
    func updateCandidates() {
        candidates = engine.lookup(reading: currentReading)
    }

    // 候補確定
    func selectCandidate(_ cand: Candidate) {
        textDocumentProxy?.insertText(cand.surface)
        clearReading()
    }

    // 直接確定（例：かな確定用）
    func commitRaw() {
        guard !currentReading.isEmpty else { return }
        textDocumentProxy?.insertText(currentReading)
        clearReading()
    }

    // 読みリセット
    func clearReading() {
        currentReading = ""
        candidates = []
    }

    // 削除キー処理
    func deleteBackward() {
        if !currentReading.isEmpty {
            currentReading.removeLast()
            updateCandidates()
        } else {
            textDocumentProxy?.deleteBackward()
        }
    }
}

