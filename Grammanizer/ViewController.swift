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

	/*
	MARK:- Lifecycle
	*/
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadQuestion()
        stackView.delegate = self
        updateQuestion()
        winView.isHidden = true
        nextButton.isEnabled = false
        nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
	}

	enum Question: String {
		case sam
		case dog
		case chicken

		var next: Question {
			switch self {
			case .sam: return .dog
			case .dog: return .chicken
			case .chicken: return .sam
			}
		}
	}

	var question = Question.sam

	func loadQuestion() {
		guard let path = Bundle.main.path(forResource: question.rawValue, ofType: "txt") else { return }
		do {
			let sampleText = try String.init(contentsOfFile: path, encoding: .utf8)
			tag(text: sampleText)
		} catch let error {
			print(error)
		}
		question = question.next
	}

	func tag(text: String) {
		let tagger = NLTagger(tagSchemes: [.lexicalClass])
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
			}
			return true
		}
        stackView.addButtons(with: info)
	}

	var tags = Set<NLTag>()

	func updateQuestion() {
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
    
    func toggleWinView(enabled: Bool) {
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

	func reset() {
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
