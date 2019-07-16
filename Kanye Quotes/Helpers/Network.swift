//
//  Network.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 16/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation

final class Network {
    var shared: Network = Network()
    
    enum Service: String {
        case chucknorris = "https://api.chucknorris.io/jokes/random"
        case kanyerest = "https://api.kanye.rest"
        case elonquotes = "https://randomelon.peterthaleikis.com/api.php"
    }
    
    
    static func fetch(service: Service) -> Quote? {
        let url = URL(string: service.rawValue)!
        let semaphore = DispatchSemaphore(value: 0)
        var quote: Quote? = nil
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            do {
                guard let data = data else { return }
                
                switch service {
                case .chucknorris:
                    quote = try JSONDecoder().decode(ChuckQuote.self, from: data).toQuote()
                    print("Chuck is here!")
                    break
                case .elonquotes:
                    quote = try JSONDecoder().decode(GeneralAPIQuote.self, from: data).toQuote(author: "Elon Musk")
                    print("Elon is here!")
                    break
                case .kanyerest:
                    quote = try JSONDecoder().decode(GeneralAPIQuote.self, from: data).toQuote(author: "Kanye West")
                    print("Kanye is here!")
                    break
                }
                
                semaphore.signal()
            } catch let error {
                print(error)
                semaphore.signal()
            }
        }.resume()
        
        
        semaphore.wait()
        
        return quote
    }
}
