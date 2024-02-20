//
//  ExercisesViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 27.12.23.
//

import UIKit
import RealmSwift
import Realm

protocol ExerciseDelegate: AnyObject {
    func didAddExercisesToWorkout(_ workout: Workout, exercises: List<Exercise>)
}

class ExercisesViewController: UIViewController {
    
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var onSaveExercises: ((List<Exercise>) -> Void)?
    
    var workout: Workout?
    var exercises: List<Exercise>?
    weak var delegate: ExerciseDelegate?
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        guard let workout = workout else {
            return
        }
        
        if realm == nil {
            realm = try? Realm()
        }
        
        tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        
        exercises = workout.exercises
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        exercises = workout?.exercises
        
        if let workoutName = workout?.name {
            workoutLabel.text = workoutName
        }
        
        if let count = exercises?.count {
            print("Number of exercises: \(count)")
        } else {
            print("No exercises found")
        }
        
        guard let workout = workout, let realm = realm else {
            return
        }
        
        do {
            try realm.write {
                for exercise in workout.exercises {
                    if realm.object(ofType: Exercise.self, forPrimaryKey: exercise.objectId) == nil {
                        realm.add(exercise)
                    }
                }
                
                exercises = workout.exercises
            }
        } catch {
            print("Error accessing Realm: \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func addExerciseButtonTapped(_ sender: Any) {
        guard let workout = workout else { return }
        let alertControllerTitle = NSLocalizedString("add_exercise_title", comment: "")
        let alertControllerMessage = NSLocalizedString("add_exercise_message", comment: "")
        
        let alertController = UIAlertController(title: alertControllerTitle, message: alertControllerMessage, preferredStyle: .alert)
        
        let exerciseNamePlaceholder = NSLocalizedString("exercise_name_placeholder", comment: "")
        let setsPlaceholder = NSLocalizedString("sets_placeholder", comment: "")
        let repetitionsPlaceholder = NSLocalizedString("repetitions_placeholder", comment: "")
        let weightPlaceholder = NSLocalizedString("weight_placeholder", comment: "")
        
        alertController.addTextField { textField in
            textField.placeholder = exerciseNamePlaceholder
        }
        
        alertController.addTextField { textField in
            textField.placeholder = setsPlaceholder
            textField.keyboardType = .numberPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = repetitionsPlaceholder
            textField.keyboardType = .numberPad
        }
        
        alertController.addTextField { textField in
            textField.placeholder = weightPlaceholder
            textField.keyboardType = .decimalPad
        }
        
        let addActionTitle = NSLocalizedString("add_action_title", comment: "")
        let addAction = UIAlertAction(title: addActionTitle, style: .default) { [weak self] _ in
            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let setsText = alertController.textFields?[1].text, !setsText.isEmpty,
                  let repetitionsText = alertController.textFields?[2].text, !repetitionsText.isEmpty,
                  let weightText = alertController.textFields?[3].text, !weightText.isEmpty,
                  let sets = Int(setsText), let repetitions = Int(repetitionsText),
                  let weight = Double(weightText)
            else { return }
            
            
            let newExercise = Exercise()
            newExercise.name = name
            newExercise.sets = sets
            newExercise.repetitions = repetitions
            newExercise.weight = weight
            workout.addExercise(newExercise)
            
            self?.tableView.reloadData()
            
        }
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action_title", comment: ""), style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
    
    func configureCell(_ cell: ExerciseTableViewCell, with exercise: Exercise) {
        cell.exerciseLabel.text = exercise.name
        let setsText = NSLocalizedString("sets_label", comment: "")
        cell.setLabel.text = "\(setsText): \(exercise.sets)"
        
        let repetitionsText = NSLocalizedString("repetitions_label", comment: "")
        cell.repetitionLabel.text = "\(repetitionsText): \(exercise.repetitions)"
        
        let weightText = NSLocalizedString("weight_label", comment: "")
        cell.weightLabel.text = "\(weightText): \(exercise.weight)"
        
    }
    @IBAction func saveChanges(_ sender: Any) {
        guard let workout = workout else { return }
        guard let realm = realm else { return }
        
        do {
            if !realm.isInWriteTransaction {
                realm.beginWrite()
            }
            
            for exercise in workout.exercises {
                realm.add(exercise, update: .modified)
            }
            
            realm.add(workout, update: .modified)
            
            if realm.isInWriteTransaction {
                try realm.commitWrite()
            }
            
            print("Exercises saved successfully:", workout.exercises)
            for exercise in workout.exercises {
                print("Exercise name:", exercise.name)
            }
            
            onSaveExercises?(workout.exercises )

            delegate?.didAddExercisesToWorkout(workout, exercises: exercises!)
            navigationController?.popViewController(animated: true)
        } catch {
            if realm.isInWriteTransaction {
                realm.cancelWrite()
            }
            print("Ошибка при сохранении тренировки: \(error)")
        }
        saveWorkout(workout)
    }
    
    func saveWorkout(_ workout: Workout) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(workout, update: .modified)
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }
}

extension ExercisesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {return UITableViewCell()}
        
        guard let exercise = exercises?[indexPath.row] else { return UITableViewCell() }
        configureCell(cell, with: exercise)
        
        
        DispatchQueue.main.async {
            print(cell.exerciseLabel.text ?? "Exercise label is empty")
            print(cell.setLabel.text ?? "Set label is empty")
            print(cell.repetitionLabel.text ?? "Repetition label is empty")
            print(cell.weightLabel.text ?? "Weight label is empty")
        }
        
        return cell
    }
}
