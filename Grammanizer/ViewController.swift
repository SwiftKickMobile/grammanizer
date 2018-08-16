//
//  ViewController.swift
//  Grammanizer
//
//  Created by Travis Buttaccio on 7/13/18.
//  Copyright © 2018 SwiftKick. All rights reserved.
//

import UIKit
import NaturalLanguage

class ViewController: UIViewController {

	/*
	MARK:- Outlets
	*/

    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var winView: UIView!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet weak var stackView: WrappingStackView!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
	@IBAction func next(_ sender: Any) {
		reset()
	}

	/*
	MARK:- Properties
	*/

	var solutions = [NLTag : Int]()
	var currentQuestion: NLTag?
	var scoreCounter = 0
    var questions: [String] = [] {
        didSet {
            loadQuestion()
            updateQuestion()
        }
    }

	/*
	MARK:- Lifecycle
	*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
        winView.isHidden = true
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        stackView.delegate = self
        getQuestions()
	}

    // MARK: - Helpers
    
    private var questionCounter: Int = 0
    
	private func loadQuestion() {
        if questionCounter >= questions.count {
            questionCounter = 0
        }
		let question = questions[questionCounter]
        tag(text: question)
        questionCounter += 1
	}
    
    private let tagger: NLTagger = NLTagger(tagSchemes: [.lexicalClass])

	private func tag(text: String) {
		tagger.string = text
		let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        var info = [ButtonInfo]()
		tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
			if let tag = tag {
				if let _ = solutions[tag] {
					solutions[tag]! += 1
				} else {
					solutions[tag] = 1
				}
				let title = String(text[tokenRange])
                info.append((tag, title))
                tags.insert(tag)
                print(title, tag.rawValue)
			}
			return true
		}
        stackView.addButtons(with: info)
	}

	private var tags = Set<NLTag>()
    
    private func updateQuestion() {
        guard let tag = tags.first else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = .white
            questionView.isHidden = true
            toggleWinView(enabled: true)
            return
        }
        tags.removeFirst()
        currentQuestion = tag
        instructions.text = "Find the \(tag.rawValue)'s."
        score.text = "0/\(solutions[tag]!)"
        scoreCounter = 0
    }
    
    private func toggleWinView(enabled: Bool) {
        if enabled {
            winView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            winView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {
                self.winView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }, completion: nil)
        } else {
            winView.isHidden = true
        }
    }

	private func reset() {
        questionView.isHidden = false
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        toggleWinView(enabled: false)
		solutions.removeAll()
		scoreCounter = 0
		tags.removeAll()
        loadQuestion()
        updateQuestion()
	}
    
    private func getQuestions() {
        questions = [
            "I, funny Sam, am playing happily and friendly at school at noon. Wow!",
            "The cat climbs a tree to search for a chicken",
            "Io sto camminando al supermercado mentre mangiando una mela",
            "The quick brown fox jumps over the lazy dog"
        ]
    }
}

extension ViewController: Delegate {
    func onSelect(_ sender: TagButton) {
        guard let currentQuestion = currentQuestion, currentQuestion == sender.nlTag else { return }
        sender.isEnabled = false
        scoreCounter += 1
        if scoreCounter >= solutions[currentQuestion]! {
            updateQuestion()
        } else {
            score.text = "\(scoreCounter)/\(solutions[currentQuestion]!)"
        }
    }
}
