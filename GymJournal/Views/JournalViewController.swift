//
//  JournalViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 30.11.23.
//

import UIKit
import Lottie

class JournalViewController: UIViewController {

    private let animationView: LottieAnimationView = {
        let lottieAnimationView = LottieAnimationView(name: "LottieForLaunchScreen")
        lottieAnimationView.backgroundColor = UIColor(red: 52/255, green: 144/255, blue: 220/255, alpha: 0.5)
        return lottieAnimationView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLottieLaunchScreen()
    }
    
    func setupLottieLaunchScreen() {
        
        view.addSubview(animationView)
  
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        animationView.alpha = 1
        
        animationView.play { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.animationView.alpha = 0
            }, completion: { _ in
                self.animationView.isHidden = true
                self.animationView.removeFromSuperview()
            })
        }
    }
}
