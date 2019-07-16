//
//  ShareToIGStoriesActivitiy.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 16/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class ShareToIGStoriesActivity: UIActivity {
    var sharedImage: Data?
    
    override class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override var activityType: UIActivity.ActivityType? {
        guard let bundleId = Bundle.main.bundleIdentifier else {return nil}
        return UIActivity.ActivityType(rawValue: bundleId + "\(self.classForCoder)")
    }
    
    override var activityTitle: String? {
        return "Instagram Stories"
    }
    
    override var activityImage: UIImage? {
        return UIImage(named: "ig-stories-logo")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for case is UIImage in activityItems {
            return true
        }
        
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        guard let image = activityItems.first as? UIImage else {
            return
        }
        
        self.sharedImage = image.pngData()
    }
    
    
    
    override func perform() {
        guard let backgroundImage = sharedImage else { return }
        
        let url = URL(string: "instagram-stories://share")
        if url!.canBeOpened {
            // Assign background image asset and attribution link URL to pasteboard
            var pasteboardItems: [[String : Any]]? = nil
            pasteboardItems = [
                [
                    "com.instagram.sharedSticker.backgroundImage": backgroundImage,
                ]
            ]
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            
            // This call is iOS 10+, can use 'setItems' depending on what versions you support
            if let pasteboardItems = pasteboardItems {
                UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            }
            
            url?.open(completion: { (opened) in
                if opened {
                    print("URL OPENED")
                    self.activityDidFinish(true)
                } else {
                    print("ERROR?")
                    self.activityDidFinish(false)
                }
            })
        }
    }
}

