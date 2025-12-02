//
//  Candidate.swift
//  Test20251201
//
//  Created by 西井勝巳 on 2025/12/01.
//

import Foundation

struct Candidate: Identifiable, Hashable {
    let id = UUID()
    let surface: String
    let reading: String
    let score: Int
}

protocol CandidateEngine {
    func lookup(reading: String) -> [Candidate]
}

final class SimpleCandidateEngine: CandidateEngine {

    private let dict: [String: [Candidate]] = [
        "しゅうせきかいろ": [
            Candidate(surface: "集積回路", reading: "しゅうせきかいろ", score: 10)
        ],
        "すいふとうあい": [
            Candidate(surface: "SwiftUI", reading: "すいふとうあい", score: 10)
        ],
        "にほん": [
            Candidate(surface: "日本", reading: "にほん", score: 10),
            Candidate(surface: "ニホン", reading: "にほん", score: 5)
        ]
    ]

    func lookup(reading: String) -> [Candidate] {
        guard !reading.isEmpty else { return [] }

        var results: [Candidate] = []

        // 前方一致：本来の IME で一番自然
        for (yomi, list) in dict where yomi.hasPrefix(reading) {
            results.append(contentsOf: list)
        }

        // 完全一致補正
        let bonus = 1000
        results.sort { lhs, rhs in
            let lhsScore = lhs.score + (lhs.reading == reading ? bonus : 0)
            let rhsScore = rhs.score + (rhs.reading == reading ? bonus : 0)
            return lhsScore > rhsScore
        }

        return Array(results.prefix(10))
    }
}

