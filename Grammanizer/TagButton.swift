//
//  TagButton.swift
//  Grammanizer
//
//  Created by Travis Buttaccio on 8/17/18.
//  Copyright © 2018 SwiftKick. All rights reserved.
//

import UIKit
import NaturalLanguage

typealias ButtonInfo = (tag: NLTag, title: String)

class TagButton: UIButton {
    var nlTag: NLTag = .other
}
