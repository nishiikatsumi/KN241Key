//
//  DictionaryLoader.swift
//  KN241Key
//
//  Created by 西井勝巳 on 2025/12/01.
//

import Foundation

final class DictionaryLoader {

    static func loadDictionary() -> [String: [Candidate]] {
        // ① バンドルを取得（キーボード拡張なら extension のバンドル）
        let bundle = Bundle.main

        // ② CSV ファイルの URL を取得
        guard let url = bundle.url(forResource: "dictionary", withExtension: "csv") else {
            print("dictionary.csv が見つかりません")
            return [:]
        }

        // ③ ファイル内容を読み込む
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("dictionary.csv の読み込みに失敗")
            return [:]
        }

        // ④ 行ごとに分割
        let lines = content.split(whereSeparator: \.isNewline)

        // ⑤ 辞書本体
        var dict: [String: [Candidate]] = [:]

        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            // 先頭行がヘッダならスキップ（例: "key,surface,reading,score"）
            if index == 0 && trimmed.hasPrefix("key") {
                continue
            }

            // ⑥ カンマで分割（単純な CSV 前提。カンマを含む値がなければ OK）
            let columns = trimmed.split(separator: ",").map { String($0) }

            // key, surface, reading, score の4列を期待
            guard columns.count >= 4 else {
                print("列数が足りません: \(columns)")
                continue
            }

            let key     = columns[0]
            let surface = columns[1]
            let reading = columns[2]
            let scoreStr = columns[3]

            guard let score = Int(scoreStr) else {
                print("score が Int に変換できません: \(scoreStr)")
                continue
            }

            let candidate = Candidate(surface: surface,
                                      reading: reading,
                                      score: score)

            // ⑦ [String: [Candidate]] に追加
            dict[key, default: []].append(candidate)
        }

        return dict
    }
}
