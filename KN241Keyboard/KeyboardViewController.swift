//
//  KeyboardViewController.swift
//  Test20251201Keyboard
//
//  Created by 西井勝巳 on 2025/12/01.
//

import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {

    private var viewModel: KeyboardViewModel!
    private var host: UIHostingController<KanaKeyboardView>?
    private var dictionary: [String: [Candidate]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // 起動時に辞書読み込み
        dictionary = DictionaryLoader.loadDictionary()
        print("辞書ロード完了。エントリ数: \(dictionary.count)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if host != nil { return }

        // 念のため、辞書が空ならここでも読み込んでおく
        if dictionary.isEmpty {
            dictionary = DictionaryLoader.loadDictionary()
        }

        let engine = DictionaryCandidateEngine(dict: dictionary)

        viewModel = KeyboardViewModel(
            textDocumentProxy: self.textDocumentProxy,
            engine: engine
        )

        let keyboardView = KanaKeyboardView(
            viewModel: viewModel,
            nextKeyboardAction: { [weak self] in
                self?.advanceToNextInputMode()
            }
        )

        let newHost = UIHostingController(rootView: keyboardView)
        self.host = newHost

        newHost.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(newHost)
        view.addSubview(newHost.view)

        NSLayoutConstraint.activate([
            newHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newHost.view.topAnchor.constraint(equalTo: view.topAnchor),
            newHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            newHost.view.heightAnchor.constraint(equalToConstant: 350)
        ])

        newHost.didMove(toParent: self)
    }
}


