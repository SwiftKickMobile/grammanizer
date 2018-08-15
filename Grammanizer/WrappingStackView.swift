//
//  WrappingStackView.swift
//  Grammanizer
//
//  Created by Travis Buttaccio on 7/18/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit
import NaturalLanguage

protocol Delegate: class {
    func onSelect(_ sender: TagButton)
}

class TagButton: UIButton {
    var nlTag: NLTag = .other
}

typealias ButtonInfo = (tag: NLTag, title: String)

class WrappingStackView: UIView {
    
    weak var delegate: Delegate?
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(stackView)
        stackView.pinEdges(to: self)
    }
    
    func addButtons(with buttonInfos: [ButtonInfo]) {
        
        stackView.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        var width: CGFloat = 0
        
        for buttonInfo in buttonInfos {
            
            // create button
            let button = createButton(with: buttonInfo)
            width += button.intrinsicContentSize.width + 8
            
            // Check if first row of buttons
            if stackView.arrangedSubviews.count <= 0 {
                addHorizontalStackView()
            }
            // check if width is greater than view width
            if width >= bounds.width {
                addHorizontalStackView()
                width = button.intrinsicContentSize.width + 8
            }
            
            // add button
            (stackView.arrangedSubviews.last as? UIStackView)?.addArrangedSubview(button)
        }
    }
    
    private func addHorizontalStackView() {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .leading
        stackView.addArrangedSubview(sv)
    }
    
    private func createButton(with buttonInfo: ButtonInfo) -> TagButton {
        let button = TagButton(type: .roundedRect)
        button.setTitle(buttonInfo.title, for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .medium)
        button.nlTag = buttonInfo.tag
        button.addTarget(self, action: #selector(onSelect), for: .touchUpInside)
        return button
    }
    
    @objc func onSelect(_ sender: TagButton) {
        delegate?.onSelect(sender)
    }
}

extension UIView {
    func pinEdges(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
