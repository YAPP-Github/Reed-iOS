// Copyright © 2025 Booket. All rights reserved
// swiftlint:disable all

import BKCore
import BKDomain
import Combine
import Foundation
import NaturalLanguage
import VisionKit
import UIKit


final class NLPPostprocessor {
    private let punctuationSet = CharacterSet.punctuationCharacters
    private let spaceLike = CharacterSet.whitespacesAndNewlines
        .union(
            CharacterSet(
                charactersIn: "\u{00A0}\u{2001}\u{2002}\u{2003}\u{2004}\u{2005}\u{2006}\u{2007}\u{2008}\u{2009}\u{200A}\u{200B}\u{202F}\u{2060}\u{3000}\u{FEFF}"
            )
        )
    private let zeroWidthLike = CharacterSet(charactersIn: "\u{200B}\u{2060}\u{FEFF}\u{00AD}")
    
    private let hangulSyllables = CharacterSet(charactersIn: "\u{AC00}"..."\u{D7A3}")
    private let hangulJamo = CharacterSet(charactersIn: "\u{1100}"..."\u{11FF}")
        .union(CharacterSet(charactersIn: "\u{3130}"..."\u{318F}"))
        .union(CharacterSet(charactersIn: "\u{A960}"..."\u{A97F}"))
        .union(CharacterSet(charactersIn: "\u{D7B0}"..."\u{D7FF}"))
    private let letterSet = CharacterSet.letters

    
    private let josa: Set<String> = [
        "을","를","은","는","이","가","도","만","의","께","뿐","조차","마저","부터","까지","마다","밖에","보다",
        "로","으로","에","에서","에게","한테"
    ]
    private let eomiShort: Set<String> = [
        "다","고","게","며","면","던","는","니","네","께","듯","데","든","란","랑","론","듯이",
        "겠","었","았","져","졌","도록","하게","하고","하며","지","서","어","아","여","자",
        "수","을","를","기","시","려","게","니","만","도","나","로","려고","면서","지만"
    ]
    private func endsWithJosa(_ s: String) -> Bool { josa.contains { s.hasSuffix($0) } }
    private func endsWithEomiShort(_ s: String) -> Bool { eomiShort.contains { s.hasSuffix($0) } }

    func spellcheckEnglishIfNeeded(_ sentences: [String]) -> [String] {
        let joined = sentences.joined(separator: "\n")
        if dominantLanguage(joined) == .english {
            return sentences.map(englishSpellCorrect)
        }
        return sentences
    }
    
    struct NLPResultSentence {
        let text: String
        let confidence: Double   // 0~1, sigmoid(avgDelta)
        let mergeCount: Int
        let avgDelta: Double
    }

    func reflowWithScores(sentences: [String]) -> [NLPResultSentence] {
        return sentences.map { reflowSentenceWithScore($0) }
    }

    func reflow(sentences: [String]) -> [String] {
        return reflowWithScores(sentences: sentences).map(\.text)
    }
    
    private func reflowSentenceWithScore(_ sentence: String) -> NLPResultSentence {
        
        let pieces = tokenize(sentence)
        let suspicious = piecesContainsSuspiciousSplit(pieces)
        let (mergedPieces, deltas, mergeCount) = mergeHangulFragmentsScored(pieces)
        let text = postSpaceClean(mergedPieces)

        let avgDelta = deltas.isEmpty ? 0.0 : (deltas.reduce(0,+) / Double(deltas.count))
        let reflowConfidence = deltas.isEmpty ? 0.5 : sigmoid(avgDelta, k: 1.0)
        let confidence = max(0.25, reflowConfidence * (suspicious ? 0.7 : 1.0))

        return NLPResultSentence(text: text,
                                 confidence: confidence,
                                 mergeCount: mergeCount,
                                 avgDelta: avgDelta)
    }
    
    private func piecesContainsSuspiciousSplit(_ pieces: [Piece]) -> Bool {
        guard pieces.count >= 3 else { return false }
        
        for i in 0..<(pieces.count - 2) {
            if case .word(let firstWord) = pieces[i],
               case .space = pieces[i+1],
               case .word(let secondWord) = pieces[i+2],
               isHangulWord(firstWord), isHangulWord(secondWord),
               (1...2).contains(firstWord.count), secondWord.count >= 2 {
                return true
            }
        }
        return false
    }

    private func sigmoid(_ x: Double, k: Double) -> Double {
        return 1.0 / (1.0 + exp(-k * x))
    }
    
    private func mergeHangulFragmentsScored(_ pieces: [Piece]) -> ([Piece], [Double], Int) {
        var result: [Piece] = []
        var deltas: [Double] = []
        var merges = 0
        var i = 0

        while i < pieces.count {
            guard case .word(let w0) = pieces[i], isHangulWord(w0) else {
                result.append(pieces[i]); i += 1; continue
            }

            var words: [String] = [w0]
            var wordIdxs: [Int] = [i]
            var spacesBetween: [String] = []
            var j = i + 1

            while j < pieces.count {
                var spaceBuf = ""
                var jj = j
                while jj < pieces.count, case let .space(sp) = pieces[jj] {
                    spaceBuf += sp; jj += 1
                }
                guard jj < pieces.count, case let .word(w) = pieces[jj], isHangulWord(w) else { break }
                words.append(w)
                wordIdxs.append(jj)
                spacesBetween.append(spaceBuf)
                j = jj + 1
                if words.count >= 5 { break }
            }

            if spacesBetween.allSatisfy({ $0.isEmpty }) {
                let (mergedWords, localDeltas, localMerges) = mergeWindowScored(words)
                mergedWords.forEach { result.append(.word($0)) }
                deltas.append(contentsOf: localDeltas)
                merges += localMerges
                i = wordIdxs.last! + 1
                continue
            }

            let joined = words.joined()
            let splitScore = words.map(scoreSingle).reduce(0,+)
            let mergedScore = scoreMerged(joined, prevLeft: nil, nextRight: nil)
            let delta = mergedScore - splitScore
            
            let last = words.last ?? ""
            var thr: Double = (endsWithJosa(joined) || endsWithEomiShort(joined)) ? 0.10 : 0.20
            
            if isNaturalKoreanVerbPattern(words) {
                thr = 0.05
            }

            if delta > thr {
                result.append(.word(joined))
                deltas.append(delta); merges += 1
                i = wordIdxs.last! + 1
            } else {
                for (idx, w) in words.enumerated() {
                    result.append(.word(w))
                    if idx < spacesBetween.count, !spacesBetween[idx].isEmpty {
                        result.append(.space(spacesBetween[idx]))
                    }
                }
                i = wordIdxs.last! + 1
            }
        }

        return (result, deltas, merges)
    }

    private func mergeWindowScored(_ words: [String]) -> ([String], [Double], Int) {
        guard !words.isEmpty else { return ([], [], 0) }
        var i = 0
        var out: [String] = []
        var deltas: [Double] = []
        var merges = 0

        while i < words.count {
            var bestText = words[i]
            var bestScore = scoreSingle(words[i])
            var bestWidth = 1
            var bestDelta = 0.0

            var j = i + 1
            while j < min(words.count, i + 5) {
                let candidate = words[i..<(j+1)].joined()
                let mergedScore = scoreMerged(
                    candidate,
                    prevLeft: i > 0 ? words[i-1] : nil,
                    nextRight: j+1 < words.count ? words[j+1] : nil
                )
                let splitScore = (i...j).map { scoreSingle(words[$0]) }.reduce(0,+)
                let delta = mergedScore - splitScore

                if mergedScore > bestScore {
                    bestScore = mergedScore
                    bestText = candidate
                    bestWidth = (j + 1) - i
                    bestDelta = delta
                }
                j += 1
            }

            out.append(bestText)
            if bestWidth > 1 { merges += 1; deltas.append(bestDelta) }
            i += bestWidth
        }

        return (out, deltas, merges)
    }


    private enum Piece {
        case word(String)
        case punct(String)
        case space(String)
    }

    private func tokenize(_ s: String) -> [Piece] {
        var pieces: [Piece] = []

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = s

        var cursor = s.startIndex
        tokenizer.enumerateTokens(in: s.startIndex..<s.endIndex) { range, _ in
            if cursor < range.lowerBound {
                let gap = s[cursor..<range.lowerBound]
                appendGapPieces(gap, into: &pieces)
            }

            pieces.append(.word(String(s[range])))

            cursor = range.upperBound
            return true
        }

        if cursor < s.endIndex {
            let gap = s[cursor..<s.endIndex]
            appendGapPieces(gap, into: &pieces)
        }

        return pieces
    }

    private func appendGapPieces(_ gap: Substring, into pieces: inout [Piece]) {
        var i = gap.startIndex
        while i < gap.endIndex {
            let ch = gap[i]

            if ch.unicodeScalars.contains(where: { zeroWidthLike.contains($0) }) {
                i = gap.index(after: i)
                continue
            }

            if ch.unicodeScalars.allSatisfy({ spaceLike.contains($0) }) {
                let start = i
                i = gap.index(after: i)
                while i < gap.endIndex,
                      gap[i].unicodeScalars.allSatisfy({ spaceLike.contains($0) }) {
                    i = gap.index(after: i)
                }
                pieces.append(.space(" "))
            } else if ch.unicodeScalars.allSatisfy({ punctuationSet.contains($0) }) {
                let start = i
                i = gap.index(after: i)
                while i < gap.endIndex,
                      gap[i].unicodeScalars.allSatisfy({ punctuationSet.contains($0) }) {
                    i = gap.index(after: i)
                }
                pieces.append(.punct(String(gap[start..<i])))
            } else {
                let start = i
                i = gap.index(after: i)
                while i < gap.endIndex {
                    let c = gap[i]
                    let isWS  = c.unicodeScalars.allSatisfy {
                        spaceLike.contains($0)
                    } || c.unicodeScalars.contains { zeroWidthLike.contains($0) }
                    let isPCT = c.unicodeScalars.allSatisfy { punctuationSet.contains($0) }
                    if isWS || isPCT { break }
                    i = gap.index(after: i)
                }
                pieces.append(.word(String(gap[start..<i])))
            }
        }
    }

    

    private func scoreSingle(_ word: String) -> Double {
        let lengthBoost = min(Double(word.count) / 4.0, 1.0)

        let shortKoreanPenalty: Double = {
            if isHangulWord(word) {
                if word.count == 1 { return -0.50 }
                if word.count == 2 { return -0.25 }
                if word.count == 3 { return -0.10 }
            }
            return 0.0
        }()

        let baseScore = 1.0
        let positionWeight = lexicalWeight(for: word)
        return baseScore + lengthBoost + positionWeight * 0.5 + shortKoreanPenalty
    }

    private func scoreMerged(_ candidate: String, prevLeft: String?, nextRight: String?) -> Double {
        let tokenCount = wordTokenCount(candidate)
        var score = tokenCount == 1 ? 3.5 : max(0.0, 2.5 - Double(tokenCount))
        
        score += lexicalWeight(for: candidate)

        if endsWithCommonEnding(candidate) { score += 0.6 }
        if endsWithJosa(candidate) { score += 0.7 }   
        if endsWithEomiShort(candidate)  { score += 0.5 }
        if isAwkwardShortMerge(candidate) { score -= 0.5 }

        if let r = nextRight, isCommonEnding(r) { score += 0.3 }
        
        if isHangulWord(candidate) && candidate.count >= 4 { score += 0.4 }
        
        if isVerbConnectivePattern(candidate) { score += 0.8 }

        return score
    }

    private func wordTokenCount(_ string: String) -> Int {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = string
        var count = 0
        tokenizer.enumerateTokens(in: string.startIndex..<string.endIndex) { _, _ in
            count += 1
            return true
        }
        return count
    }

    private func lexicalWeight(for string: String) -> Double {
        if isHangulWord(string) {
            return string.count >= 3 ? 1.0 : 0.7
        }

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = string
        let (tag, _) = tagger.tag(at: string.startIndex, unit: .word, scheme: .lexicalClass)
        switch tag {
        case .noun, .verb, .adjective, .adverb, .particle, .number: return 1.0
        case .other, nil: return 0.0
        default: return 0.5
        }
    }

    private let commonEndings: Set<String> = [
        "도록", "하게", "하고", "하며", "하니", "하면", "해서",
        "된다", "된다면", "됩니다", "된다니", "되었다", "되었고", "되었네",
        "합니다", "하였다", "하였다가", "했지만", "했으며", "하면서",
        "이다", "입니다", "였다", "였다가", "이었다", "이지만",
        "으로", "에게", "에서", "까지", "부터", "이라서", "이라면",
        "같다", "없다", "있다", "싶다", "싶어서", "싶으면"
    ]

    private func endsWithCommonEnding(_ s: String) -> Bool {
        for e in commonEndings where s.hasSuffix(e) { return true }
        return false
    }

    private func isCommonEnding(_ s: String) -> Bool {
        return commonEndings.contains(s) || s == "록" || s == "게" || s == "고" || s == "며"
    }

    private func isAwkwardShortMerge(_ s: String) -> Bool {
        return s.count == 2
    }
    
    private func isVerbConnectivePattern(_ string: String) -> Bool {
        let patterns = [
            "고싶고", "지않고", "어야하고", "수있고", "게되고", "어서하고", 
            "지만하고", "려면하고", "면되고", "어야되고", "을수있고", "를수있고"
        ]
        return patterns.contains { string.contains($0) } || 
               (string.contains("고") && (string.contains("하") || string.contains("되") || string.contains("있")))
    }
    
    private func isNaturalKoreanVerbPattern(_ words: [String]) -> Bool {
        if words.count == 2 {
            let combined = words.joined()
            let patterns = [
                "하고", "가고", "오고", "보고", "말고", "살고", "먹고", "마시고", "읽고", "쓰고", "듣고",
                "하지", "가지", "오지", "보지", "말지", "살지", "먹지", "마시지", "읽지", "쓰지", "듣지",
                "했고", "갔고", "왔고", "봤고", "말했고", "살았고", "먹었고", "마셨고", "읽었고", "썼고", "들었고"
            ]
            return patterns.contains { combined.contains($0) }
        }
        
        if words.count == 3 {
            let combined = words.joined()
            let patterns = [
                "살고싶고", "하고싶고", "가고싶고", "보고싶고", "먹고싶고", "마시고싶고",
                "할수있고", "갈수있고", "볼수있고", "먹을수있고", "마실수있고",
                "하지않고", "가지않고", "보지않고", "먹지않고", "마시지않고"
            ]
            return patterns.contains { combined.contains($0) }
        }
        
        return false
    }

    // MARK: - Utilities

    private func isHangulWord(_ w: String) -> Bool {
        guard !w.isEmpty else { return false }
        var hangul = 0, letters = 0
        for sc in w.unicodeScalars {
            if hangulSyllables.contains(sc) || hangulJamo.contains(sc) { hangul += 1 }
            if letterSet.contains(sc) || hangulSyllables.contains(sc) || hangulJamo.contains(sc) {
                letters += 1
            }
        }
        if letters == 0 { return false }
        return Double(hangul) / Double(letters) >= 0.6
    }

    private func dominantLanguage(_ text: String) -> NLLanguage? {
        let r = NLLanguageRecognizer()
        r.processString(text)
        return r.dominantLanguage
    }

    private func englishSpellCorrect(_ s: String) -> String {
        let checker = UITextChecker()
        var text = s
        var ns = text as NSString
        var search = NSRange(location: 0, length: ns.length)

        while true {
            let range = checker.rangeOfMisspelledWord(
                in: text,
                range: search,
                startingAt: search.location,
                wrap: false,
                language: "en"
            )
            if range.location == NSNotFound { break }
            let guesses = checker.guesses(forWordRange: range, in: text, language: "en") ?? []
            if let best = guesses.first {
                ns = ns.replacingCharacters(in: range, with: best) as NSString
                text = ns as String
                let nextLoc = range.location + (best as NSString).length
                search = NSRange(location: nextLoc, length: ns.length - nextLoc)
            } else {
                let nextLoc = range.location + range.length
                search = NSRange(location: nextLoc, length: ns.length - nextLoc)
            }
        }
        return text
    }

    private func postSpaceClean(_ pieces: [Piece]) -> String {
        var s = pieces.map {
            switch $0 {
            case .word(let w): return w
            case .punct(let p): return p
            case .space(let sp): return sp
            }
        }.joined()

        s = s.replacingOccurrences(of: "\\s+([.,?!…])", with: "$1", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        return s.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
