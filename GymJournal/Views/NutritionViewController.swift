//
//  NutritionViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 30.11.23.
//

import UIKit

class NutritionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var nutritionLabel: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var height: UILabel!
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var lifestyleTextField: UITextField!
    @IBOutlet weak var lifestyle: UILabel!
    
    @IBOutlet weak var goal: UILabel!
    
    @IBOutlet weak var goalSegment: UISegmentedControl!
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var calories: UILabel!
    
    @IBOutlet weak var proteins: UILabel!
    
    @IBOutlet weak var fats: UILabel!
    
    
    @IBOutlet weak var carbohydrates: UILabel!
    
    let activityLevels = [
        NSLocalizedString("Almost no activity", comment: ""),
        NSLocalizedString("Low activity", comment: ""),
        NSLocalizedString("Moderate activity", comment: ""),
        NSLocalizedString("High activity", comment: ""),
        NSLocalizedString("Extreme activity", comment: "")
    ]
    let activityCoefficients = [1.2, 1.375, 1.55, 1.7, 1.9]
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        lifestyleTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(pickerDoneButtonPressed))
        toolbar.setItems([doneButton], animated: false)
        lifestyleTextField.inputAccessoryView = toolbar
        
        nutritionLabel.text = NSLocalizedString("Nutrition Calculator", comment: "")
        gender.text = NSLocalizedString("Your Gender:", comment: "")
        genderSegment.setTitle(NSLocalizedString("Male", comment: ""), forSegmentAt: 0)
        genderSegment.setTitle(NSLocalizedString("Female", comment: ""), forSegmentAt: 1)
        age.text = NSLocalizedString("Age:", comment: "")
        height.text = NSLocalizedString("Height (cm):", comment: "")
        weight.text = NSLocalizedString("Weight (kg):", comment: "")
        lifestyle.text = NSLocalizedString("Activity Level:", comment: "")
        goal.text = NSLocalizedString("Goal:", comment: "")
        goalSegment.setTitle(NSLocalizedString("Lose Weight", comment: ""), forSegmentAt: 0)
        goalSegment.setTitle(NSLocalizedString("Gain Weight", comment: ""), forSegmentAt: 1)
        goalSegment.setTitle(NSLocalizedString("Maintain Weight", comment: ""), forSegmentAt: 2)
        calculateButton.setTitle(NSLocalizedString("Calculate", comment: ""), for: .normal)
        calories.text = NSLocalizedString("Calories:", comment: "")
        proteins.text = NSLocalizedString("Proteins:", comment: "")
        fats.text = NSLocalizedString("Fats:", comment: "")
        carbohydrates.text = NSLocalizedString("Carbohydrates:", comment: "")
    }
    
    
    
    
    @IBAction func calculate(_ sender: Any) {
        calculateNutrition()
    }
    
    func calculateNutrition() {
        guard let ageText = ageTextField.text,
              let heightText = heightTextField.text,
              let weightText = weightTextField.text,
              let lifestyleText = lifestyleTextField.text,
              let gender = genderSegment.titleForSegment(at: genderSegment.selectedSegmentIndex)
        else {
            return
        }
        
        print("Got input values: Age: \(ageText), Height: \(heightText), Weight: \(weightText), Lifestyle: \(lifestyleText), Gender: \(gender)")
        
        guard let age = Double(ageText),
              let height = Double(heightText),
              let weight = Double(weightText)
        else {
            print("Failed to convert input values to Double")
            return
        }
        
        print("Converted input values to Double: Age: \(age), Height: \(height), Weight: \(weight)")
        
        var baseFormula: Double
        if gender.lowercased() == "male" {
            baseFormula = (10 * weight + 6.25 * height - 5 * age + 5)
        } else {
            baseFormula = (10 * weight + 6.25 * height - 5 * age - 161)
        }
        
        print("Calculated baseFormula: \(baseFormula)")
        
        let selectedActivityLevelIndex = pickerView.selectedRow(inComponent: 0)
        guard selectedActivityLevelIndex < activityCoefficients.count else {
            print("Invalid selectedActivityLevelIndex")
            return
        }
        
        let selectedActivityLevel = activityCoefficients[selectedActivityLevelIndex]
        let totalCalories = baseFormula * selectedActivityLevel
        
        let goalMultiplier: Double
        switch goalSegment.selectedSegmentIndex {
        case 0:
            goalMultiplier = 0.85
        case 1:
            goalMultiplier = 1.15
        case 2:
            goalMultiplier = 1.0
        default:
            goalMultiplier = 0.85
        }
        
        let adjustedCalories = totalCalories * goalMultiplier
        
        let proteinGrams = (adjustedCalories * 0.3) / 4
        let fatGrams = (adjustedCalories * 0.3) / 9
        let carbGrams = (adjustedCalories * 0.4) / 4
        
        print("Age: \(ageText), Height: \(heightText), Weight: \(weightText), Lifestyle: \(lifestyleText), Gender: \(gender)")
        
        let roundedCalories = adjustedCalories.rounded()
        let roundedProteins = proteinGrams.rounded()
        let roundedFats = fatGrams.rounded()
        let roundedCarbs = carbGrams.rounded()
        
        print("Age: \(ageText), Height: \(heightText), Weight: \(weightText), Lifestyle: \(lifestyleText), Gender: \(gender)")
        
        DispatchQueue.main.async {
            self.calories.text = "Каллории: \(roundedCalories) ккал"
            self.proteins.text = "Белки: \(roundedProteins) г"
            self.fats.text = "Жиры: \(roundedFats) г"
            self.carbohydrates.text = "Углеводы: \(roundedCarbs) г"
        }
        
    }
    
    // MARK: UIPickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityLevels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityLevels[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lifestyleTextField.text = activityLevels[row]
    }
    
    @objc func pickerDoneButtonPressed() {
        lifestyleTextField.resignFirstResponder()
    }
    
}
