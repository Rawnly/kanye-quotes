//
//  Quotes.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 16/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation

struct Quote {
    var author: String
    var text: String
}

protocol QuoteProtocol {
    func toQuote(author: String) -> Quote
}

struct ChuckQuote: Decodable, QuoteProtocol {
    var value: String
    
    func toQuote(author: String = "Chuck Norris") -> Quote {
        return Quote(author: author, text: value)
    }
}

struct GeneralAPIQuote: Decodable, QuoteProtocol {
    var quote: String
    
    func toQuote(author: String) -> Quote {
        return Quote(author: author, text: quote)
    }
}

