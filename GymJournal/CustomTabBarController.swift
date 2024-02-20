//
//  CustomTabBarController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 20.02.24.
//

import Foundation
import UIKit

class CustomTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 75
        return sizeThatFits
    }
}

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let customTabBar = CustomTabBar()
        setValue(customTabBar, forKey: "tabBar")

        tabBar.barTintColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.7)
 
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -5)
        tabBar.layer.shadowRadius = 6
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.2
        

        let journalVC = JournalViewController()
        journalVC.title = NSLocalizedString("workouts_title", comment: "")
        
        let nutritionVC = NutritionViewController()
        nutritionVC.title = NSLocalizedString("nutrition_title", comment: "")
        
        let settingsVC = SettingsViewController()
        settingsVC.title = NSLocalizedString("settings_title", comment: "")
        
        let navJournal = UINavigationController(rootViewController: journalVC)
        let navNutrition = UINavigationController(rootViewController: nutritionVC)
        let navSettings = UINavigationController(rootViewController: settingsVC)
        

        viewControllers = [navJournal, navNutrition, navSettings]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
            .foregroundColor: UIColor.black
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "HelveticaNeue-Bold", size: 20)!,
            .foregroundColor: UIColor.blue
        ]
        
        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
        
        addTabBarSeparators()
    }
    
    private func addTabBarSeparators() {
        guard let items = tabBar.items else { return }
        
        let separatorWidth: CGFloat = 1
        
        let totalSeparators = items.count - 1
        
        let tabWidth = tabBar.frame.width / CGFloat(items.count)
        
        for i in 1...totalSeparators {
                    let separator = CALayer()
                    separator.backgroundColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                    separator.frame = CGRect(x: CGFloat(i) * tabWidth - separatorWidth / 2, y: 0, width: separatorWidth, height: tabBar.frame.height - 20) 
                    tabBar.layer.addSublayer(separator)
                }
    }
}
