//
//  SettingsViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 30.11.23.
//

import UIKit

protocol LocalizationDelegate: AnyObject {
    func updateLocalization()
}

class SettingsViewController: UIViewController {
    
    weak var localizationDelegate: LocalizationDelegate?
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var localizationSegment: UISegmentedControl!
    
    let quoteLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let getQuoteButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("get_quote_button_title", comment: ""), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languageLabel.text = NSLocalizedString("Language:", comment: "")
        
        if let appLanguage = UserDefaults.standard.string(forKey: "AppLanguages") {
               print("App Language:", appLanguage)
               switch appLanguage {
               case "ru":
                   localizationSegment.selectedSegmentIndex = 0
               case "en":
                   localizationSegment.selectedSegmentIndex = 1
               default:
                   break
               }
           }
        
        setupUI()
        fetchQuoteOfTheDay()
    }
    @IBAction func changeLanguage(_ sender: UISegmentedControl) {
        let selectedLanguage: String
            switch sender.selectedSegmentIndex {
            case 0:
                selectedLanguage = "ru"
            case 1:
                selectedLanguage = "en"
            default:
                return
            }
            
            UserDefaults.standard.set(selectedLanguage, forKey: "AppLanguages")
        localizationDelegate?.updateLocalization()
    }
    
    func setupUI() {
        view.addSubview(quoteLabel)
        view.addSubview(getQuoteButton)
        
        NSLayoutConstraint.activate([
            quoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quoteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            getQuoteButton.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 20),
            getQuoteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        getQuoteButton.addTarget(self, action: #selector(getQuoteButtonTapped), for: .touchUpInside)
    }
    
    @objc func getQuoteButtonTapped() {
        fetchQuoteOfTheDay()
    }
    
    func fetchQuoteOfTheDay() {
        guard let url = URL(string: "https://favqs.com/api/qotd") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching quote:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let quoteData = try JSONDecoder().decode(QuoteResponse.self, from: data)
                
                if let quoteBody = quoteData.quote.body {
                    DispatchQueue.main.async {
                        self.quoteLabel.text = quoteBody
                    }
                } else {
                    print("Error: Quote body is nil")
                }
            } catch {
                print("Error decoding quote:", error.localizedDescription)
            }
        }.resume()
    }
}

struct QuoteResponse: Codable {
    let quote: Quote
}

struct Quote: Codable {
    let body: String?
}
