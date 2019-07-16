//
//  ViewController.swift
//  Kanye Quotes
//
//  Created by Federico Vitale on 15/07/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var quote: UILabel = UILabel();
    var copyButton: UIButton = UIButton();
    var tweetBtn: UIButton = UIButton()
    var hintLabel: UILabel = UILabel()
    var counter: UILabel = UILabel()
    var author: UILabel = UILabel()
    var iconImage: UIImageView = UIImageView()
    
    var hints: [String] = [
        "Tap anywhere to get a new quote",
        "Swipe right to get back",
        "Swipe up to share"
    ]
    
    var hintsIndex : Int = 0
    
    var prevQuote: Quote? = nil
    var currentQuote: Quote? = nil
    var nextQuote: Quote? = nil
    var canGoBack: Bool = true
    var isStarted: Bool = false
    
    var theme: Theme {
        get {
            return Preferences.theme
        }
        
        set {
            Preferences.theme = newValue
        }
    }

    /*
     * -----------------------
     * MARK: - Lifecycle
     * ------------------------
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let newQuoteTap = UITapGestureRecognizer(target: self, action: #selector(setRandomQuote))
        view.addGestureRecognizer(newQuoteTap)
        
        let toggleDarkThemeLongPress = UILongPressGestureRecognizer(target: self, action: #selector(toggleDarkTheme))
        view.addGestureRecognizer(toggleDarkThemeLongPress)
        
        let swipeUpToShare = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUpToShare))
        swipeUpToShare.direction = .up
        view.addGestureRecognizer(swipeUpToShare)
        
        let swipeRightToPrevQuote = UISwipeGestureRecognizer(target: self, action: #selector(getPrevQuote))
        swipeRightToPrevQuote.direction = .right
        view.addGestureRecognizer(swipeRightToPrevQuote)
        
        view.backgroundColor = ThemeManager.backgroundColor
        
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { (_) in
            if ( self.copyButton.alpha == 1 ) {
                self.getNextHint()
            }
        }
        
        currentQuote = self.getQuote(author: [.chucknorris, .elonquotes, .kanyerest].randomElement()!)
        
        if #available(iOS 13.0, *) {
            hints.append("You can toggle dark mode from system preferences")
            
            if traitCollection.userInterfaceStyle == .dark {
                theme = .dark
            } else {
                theme = .light
            }
        } else {
            hints.append("Long press to toggle Dark Mode")
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUIForTheme), name: .ThemeDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .ThemeDidChange, object: nil)
    }
    
    /*
     * -----------------------
     * MARK: - Utility
     * ------------------------
     */
    private func getQuote(author: Network.Service) -> Quote {
        return Network.fetch(service: author)!
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme == .dark ? .lightContent : .default
    }
}


/*
 * -----------------------
 * MARK: - Actions
 * ------------------------
 */
extension ViewController {
    @objc
    func handleSwipeUpToShare(gesture: UISwipeGestureRecognizer) {
        guard gesture.direction == .up, isStarted == true else { return }
        
        switch gesture.state {
        case .ended:
            // Hide ui
            copyButton.alpha = 0
            hintLabel.alpha = 0
            counter.alpha = 0
            
            let backgroundImage = takeScreenshot(of: view)!
            
            let vc = UIActivityViewController(activityItems: [backgroundImage], applicationActivities: [ShareToIGStoriesActivity()])
            present(vc, animated: true)
            
            // Show ui
            copyButton.alpha = 1
            hintLabel.alpha = 1
            counter.alpha = 1
            break
        default:
            return
        }
    }
    
    @objc
    func updateUIForTheme() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = ThemeManager.backgroundColor
            
            self.copyButton.setTitleColor(ThemeManager.backgroundColor, for: .normal)
            self.copyButton.backgroundColor = ThemeManager.textColor
            
            self.quote.textColor = .label
            self.hintLabel.textColor = .tertiaryLabel
            self.counter.textColor = .secondaryLabel
            self.author.textColor = .secondaryLabel
            
            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    @objc
    func toggleDarkTheme(gesture: UILongPressGestureRecognizer) {
        if #available(iOS 13.0, *) {
            return
        }
        
        switch gesture.state {
        case .began:
            theme = theme == .light ? .dark : .light
            break
        default:
            break
        }
    }
    
    @objc
    func setRandomQuote() {
        setQuote()
        canGoBack = true
    }
    
    func setQuote(to: Quote? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.quote.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            self.quote.alpha = 0
            self.author.alpha = 0
        }) { _ in
            DispatchQueue.global(qos: .background).async {
                let services: [Network.Service] = [.chucknorris, .elonquotes, .kanyerest]
                var quote: Quote!
                
                if !self.isStarted {
                    quote = self.currentQuote
                    self.canGoBack = false
                    self.isStarted = true
                } else {
                    quote = to ?? (self.nextQuote ?? self.getQuote(author: services.randomElement()!))
                }
                
                self.prevQuote = self.currentQuote
                self.currentQuote = quote
                
                DispatchQueue.main.async {
                    self.quote.text = quote.text
                    self.author.text = quote.author
                    
                    DispatchQueue.global(qos: .background).async {
                        self.nextQuote = self.getQuote(author: services.randomElement()!)
                    }
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.quote.transform = CGAffineTransform.identity
                        self.quote.alpha = 1
                        self.author.alpha = 0.4
                        
                        
                        if ( self.copyButton.alpha == 0 ) {
                            self.copyButton.alpha = 1
                            self.copyButton.transform = .identity
                        }
                        
                        if ( self.counter.alpha == 0 ) {
                            self.counter.alpha = 1
                            self.counter.transform = .identity
                        }
                    })
                }
            }
        }
    }
    
    @objc
    func getNextHint() {
        UIView.animate(withDuration: 0.25, animations: {
            self.hintLabel.alpha = 0
        }) { (_) in
            self.hintLabel.text = self.hints[self.hintsIndex]
            
            if ( self.hintsIndex == self.hints.count - 1) {
                self.hintsIndex = 0
            } else {
                self.hintsIndex += 1
            }
            
            UIView.animate(withDuration: 0.25, animations: {
                self.hintLabel.alpha = 0.4
            })
        }
    }
    
    @objc
    func getPrevQuote() {
        if canGoBack {
            setQuote(to: self.prevQuote)
            canGoBack = false
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.quote.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
                self.quote.alpha = 0.8
                self.author.alpha = 0.2
            }) { _ in
                UIView.animate(withDuration: 0.25, animations: {
                    self.quote.transform = .identity
                    self.quote.alpha = 1
                    self.author.alpha = 0.4
                })
            }
        }
    }
    
    @objc
    func copyToClipboard(_ sender: UIButton) {
        UIPasteboard.general.string = quote.text!
        
        let alert = UIAlertController(title: "Copied!", message: "Quote copied!", preferredStyle: .alert)
        alert.addAction(.init(title: "Cool!", style: .default, handler: nil))
        
        present(alert, animated: true);
    }
    
    func updateCounter(to: Int) {
        UIView.animate(withDuration: 0.15, animations: {
            self.counter.alpha = 0.4
        }) { (_) in
            self.counter.text = "\(to)/\(quotes.count)"
            UIView.animate(withDuration: 0.15, animations: {
                self.counter.alpha = 1
            })
        }
    }
}


/*
 * -----------------------
 * MARK: - UI
 * ------------------------
 */
extension ViewController {
    private func setupUI() -> Void {
        setupLabel()
        setupButton()
        setupHint()
        setupCounter()
        setupAuthor()
    }
    
    private func setupLabel() -> Void {
        quote.numberOfLines = 0
        quote.textColor = ThemeManager.textColor
        quote.text = "Tap anywhere to start"
        quote.textAlignment = .center
        quote.font = .boldSystemFont(ofSize: 20)
        quote.addParallaxEffect()
        
        quote
            .addToView(view)
            .setConstraints([
              quote.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
              quote.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
            ])
            .centerInSuperView()
    }
    
    private func setupButton() -> Void {
        copyButton.backgroundColor = ThemeManager.textColor
        copyButton.setTitle("Copy", for: .normal)
        copyButton.setTitleColor(ThemeManager.backgroundColor, for: .normal)
        copyButton.layer.cornerRadius = 5
        copyButton.addShadow(offset: .init(width: 2, height: 2), opacity: 0.2, radius: 10)
        
        copyButton.addTarget(self, action: #selector(copyToClipboard), for: .touchUpInside);
        
        copyButton.alpha = 0
        copyButton.transform = .init(translationX: 0, y: 50)
        
        if let label = copyButton.titleLabel {
            label.font = .boldSystemFont(ofSize: 22)
            label.textAlignment = .center
        }
        
        copyButton
            .addToView(view)
            .centerInSuperView(axis: .x)
            .setConstraints([
                copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
                copyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
                copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
            ])
    }
    
    private func setupHint() -> Void {
        hintLabel.textColor = ThemeManager.textColor
        hintLabel.text = ""
        hintLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hintLabel.alpha = 0.4
        hintLabel
            .addToView(view)
            .centerInSuperView(axis: .x)
            .setConstraints([
                hintLabel.bottomAnchor.constraint(equalTo: copyButton.topAnchor, constant: -10)
            ])
    }
    
    private func setupCounter() -> Void {
        counter.textColor = ThemeManager.textColor
        counter.text = "Suggest a resource"
        
        counter.alpha = 0
        counter.transform = .init(translationX: 0, y: -50)
        
        counter.font = .boldSystemFont(ofSize: 17)
        counter
            .addToView(view)
            .setConstraints([
                counter.topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
            ])
            .centerInSuperView(axis: .x)
    }
    
    private func setupAuthor() {
        author.textColor = ThemeManager.textColor
        author.alpha = 0
        author.text = "Kanye West"
        author.textAlignment = .center
        author.font = .systemFont(ofSize: 12, weight: .medium)
        
        author
            .addToView(view)
            .setConstraints([
                author.topAnchor.constraint(equalTo: quote.bottomAnchor, constant: 15)
            ])
            .centerInSuperView(axis: .x)
    }
}

/*
 * -----------------------
 * MARK: - Theming
 * ------------------------
 */
extension ViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.userInterfaceStyle == .dark {
            theme = .dark
        } else {
            theme = .light
        }
    }
}



extension Notification.Name {
    static let ThemeDidChange: Notification.Name = Notification.Name(rawValue: "ThemeDidChange")
}
