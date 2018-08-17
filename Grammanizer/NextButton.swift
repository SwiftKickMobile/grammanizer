//
//  NextButton.swift
//  Grammanizer
//
//  Created by Travis Buttaccio on 8/17/18.
//  Copyright © 2018 SwiftKick. All rights reserved.
//

import UIKit

class NextButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .white
            } else {
                backgroundColor = UIColor.white.withAlphaComponent(0.3)
            }
        }
    }
}
