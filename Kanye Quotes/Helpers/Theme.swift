//
//  Theme.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 15/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int {
    case light = 0
    case dark = 1
}


struct ThemeManager {
    static var theme: Theme {
        return Preferences.theme
    }
    
    static var backgroundColor: UIColor {
        return self.theme == .light ? .white : .black
    }
    
    static var textColor: UIColor {
        return self.theme == .light ? .black : .white
    }
    
    static var accentColor: UIColor {
        return self.theme == .light ? .blue : .yellow
    }
}
