//
//  WrappingStackView.swift
//  Grammanizer
//
//  Created by Travis Buttaccio on 7/18/18.
//  Copyright © 2018 SwiftKick Mobile. All rights reserved.
//

import UIKit

protocol WrappingButtonViewDelegate: class {
    func buttonPressed(_ sender: TagButton)
}

class WrappingButtonView: UIView {
    
    // MARK: - API
    
    weak var delegate: WrappingButtonViewDelegate?
    
    var buttons = [ButtonInfo]() {
        didSet {
            addButtons(with: buttons)
        }
    }
    
    // MARK: - Actions
    
    @objc func onSelect(_ sender: TagButton) {
        delegate?.buttonPressed(sender)
    }
    
    // MARK: - Properties
    
    private let spacing: CGFloat = 8
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(stackView)
        stackView.pinEdges(to: self)
    }
    
    // MARK: - Helpers
    
    private func addButtons(with buttonConfigs: [ButtonInfo]) {
        
        stackView.arrangedSubviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        var width: CGFloat = 0
        
        for buttonConfig in buttonConfigs {
            // create button
            let button = createButton(with: buttonConfig)
            width += button.intrinsicContentSize.width + spacing
            // Check if first row of buttons
            if stackView.arrangedSubviews.count <= 0 {
                addHorizontalStackView()
            }
            // check if width is greater than view width
            if width >= bounds.width {
                addHorizontalStackView()
                width = button.intrinsicContentSize.width + spacing
            }
            // add button
            (stackView.arrangedSubviews.last as? UIStackView)?.addArrangedSubview(button)
        }
    }
    
    private func addHorizontalStackView() {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = spacing
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
