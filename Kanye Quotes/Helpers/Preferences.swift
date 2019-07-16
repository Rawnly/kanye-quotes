//
//  Preferences.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 15/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation

struct Preferences {
    static var theme: Theme {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: .theme)
            self.sync()
            
            NotificationCenter.default.post(name: .ThemeDidChange, object: nil)
        }
        
        get {
            if let index = UserDefaults.standard.integer(forKey: .theme) {
                return Theme(rawValue: index) ?? .light
            }
            
            return .light
        }
    }
    
    static func sync() -> Void {
        UserDefaults.standard.synchronize()
    }
}


extension UserDefaults {
    enum Key: String {
        case theme = "theme"
    }
    
    func set<T>(_ value: T, forKey key: Key) {
        set(value, forKey: key.rawValue)
    }
    
    func bool(forKey key: Key) -> Bool {
        return bool(forKey: key.rawValue)
    }
    
    func string(forKey key: Key) -> String? {
        return string(forKey: key.rawValue)
    }
    
    func integer(forKey key: Key) -> Int? {
        return integer(forKey: key.rawValue)
    }
    
    func url(forKey key: Key) -> URL? {
        return url(forKey: key.rawValue)
    }
}
