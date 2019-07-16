//
//  SocialMediaHelper.swift
//  Stockpapers
//
//  Created by Federico Vitale on 17/03/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

class SocialMediaHelper {
    struct ShareOnInstaStoriesOptions {
        var indicator: UIActivityIndicatorView? = nil
    }
    
    public static func shareOnInstaStories(backgroundImage: Data?, stickerImage: Data?, options: ShareOnInstaStoriesOptions? = nil, completion: ((Bool, String?) -> Void)? = nil) {
        options?.indicator?.startAnimating()
        
        let url = URL(string: "instagram-stories://share")
        if url!.canBeOpened {
            if backgroundImage == nil && stickerImage == nil {
                options?.indicator?.stopAnimating()
                completion?(false, "No background/sticker image")
                return
            }
            
            // Assign background image asset and attribution link URL to pasteboard
            var pasteboardItems: [[String : Any]]? = nil
            if let backgroundImage = backgroundImage {
                var items = [
                    "com.instagram.sharedSticker.backgroundImage": backgroundImage
                ]
                
                if let stickerImage = stickerImage {
                    items["com.instagram.sharedSticker.stickerImage"] = stickerImage
                }
                
                pasteboardItems?.append(items)
            }
            
            
            let pasteboardOptions = [
                UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(60 * 5)
            ]
            
            // This call is iOS 10+, can use 'setItems' depending on what versions you support
            if let pasteboardItems = pasteboardItems {
                UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            }
            
            url?.open(completion: { (opened) in
                if let indicator = options?.indicator {
                    print("ERROR")
                    indicator.stopAnimating()
                }
                
                completion?(opened, nil)
            })
            
            return
        }
        
        options?.indicator?.stopAnimating()
        completion?(false, "Can't open the URL")
    }
}



extension URL {
    var canBeOpened: Bool {
        return UIApplication.shared.canOpenURL(self)
    }
    
    init(string main: String, fallback secondary: String) {
        let url = URL(string: main)
        let fallback = URL(string: secondary)
        
        if UIApplication.shared.canOpenURL(url!) {
            self = url!
        } else {
            self = fallback!
        }
    }
    
    func open(withFallback str: String) -> URL! {
        let fallback = URL(string: str)!
        
        if UIApplication.shared.canOpenURL(self) {
            return self
        }
        
        return fallback
    }
    
    func open(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(self, options: options, completionHandler: completion)
    }
    
    func safeOpen(options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completion: ((Bool) -> Void)?, onFail: @escaping (_ errorMessage: String) -> Void) {
        
        if self.canBeOpened {
            self.open(completion: completion)
            return
        }
        
        onFail("Can't open the URL")
    }
}
