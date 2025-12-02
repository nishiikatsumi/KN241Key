//
//  DictionaryCandidateEngine.swift
//  KN241Key
//
//  Created by 西井勝巳 on 2025/12/01.
//

final class DictionaryCandidateEngine: CandidateEngine {

    private let dict: [String: [Candidate]]

    init(dict: [String: [Candidate]]) {
        self.dict = dict
    }

    func lookup(reading: String) -> [Candidate] {
        guard !reading.isEmpty else { return [] }

        var results: [Candidate] = []

        // key が読み（かな）だと仮定して、前方一致で検索
        for (key, list) in dict where key.hasPrefix(reading) {
            results.append(contentsOf: list)
        }

        // 完全一致にボーナスをつけてスコア順にソート
        let bonus = 1000
        results.sort { lhs, rhs in
            let lhsScore = lhs.score + (lhs.reading == reading ? bonus : 0)
            let rhsScore = rhs.score + (rhs.reading == reading ? bonus : 0)
            return lhsScore > rhsScore
        }

        return Array(results.prefix(10))
    }
}
