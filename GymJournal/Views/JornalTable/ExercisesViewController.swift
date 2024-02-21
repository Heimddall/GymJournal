//
//  ExercisesViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 27.12.23.
//

import UIKit
import RealmSwift
import Realm

class ExercisesViewController: UIViewController {
    
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var workout: Workout?
    var exercises: List<Exercise>?
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = DatabaseManager.shared.realm
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        guard let workout = workout else {
            return
        }
        exercises = workout.exercises
        print("Exercises for the current workout:", exercises ?? "No exercises")
        
        tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
    
        workoutLabel.text = workout.name
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let workout = workout {
            exercises = workout.exercises
            tableView.reloadData()
        }
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
            newExercise.workout = workout
            
            workout.addExercise(newExercise)
            self?.exercises = workout.exercises
            self?.tableView.reloadData()
        }
        
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action_title", comment: ""), style: .cancel)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func configureCell(_ cell: ExerciseTableViewCell, with exercise: Exercise) {
        let maximumLabelWidth: CGFloat = 160
        let labelFont = UIFont.systemFont(ofSize: 17)
        
        let exerciseName = exercise.name
        cell.exerciseLabel.text = exerciseName
        
        let labelSize = exerciseName.size(withAttributes: [.font: labelFont])
        if labelSize.width > maximumLabelWidth {
            let availableWidth = maximumLabelWidth - 30
            let numberOfCharsToShow = Int((availableWidth / labelSize.width) * CGFloat(exerciseName.count))
            
            let truncatedName = String(exerciseName.prefix(numberOfCharsToShow)) + "..."
            cell.exerciseLabel.text = truncatedName
        } else {
            cell.exerciseLabel.text = exerciseName
        }
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

            navigationController?.popViewController(animated: true)
        } catch {
            if realm.isInWriteTransaction {
                realm.cancelWrite()
            }
            print("Ошибка при сохранении тренировки: \(error)")
        }
        
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let selectedExercise = exercises?[indexPath.row]
                
                let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
                    self?.editExercise(selectedExercise)
                }
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    self?.deleteExercise(at: indexPath)
                }
                
                let alertController = UIAlertController(title: "Exercise Options", message: nil, preferredStyle: .actionSheet)
                alertController.addAction(editAction)
                alertController.addAction(deleteAction)
                present(alertController, animated: true)
            }
        }
    }
    
    func editExercise(_ exercise: Exercise?) {
        guard let exercise = exercise else { return }
        
        let alertControllerTitle = NSLocalizedString("edit_exercise_title", comment: "")
        let alertControllerMessage = NSLocalizedString("edit_exercise_message", comment: "")
        
        let alertController = UIAlertController(title: alertControllerTitle, message: alertControllerMessage, preferredStyle: .alert)
        
        let exerciseNamePlaceholder = NSLocalizedString("exercise_name_placeholder", comment: "")
        let setsPlaceholder = NSLocalizedString("sets_placeholder", comment: "")
        let repetitionsPlaceholder = NSLocalizedString("repetitions_placeholder", comment: "")
        let weightPlaceholder = NSLocalizedString("weight_placeholder", comment: "")
        
        alertController.addTextField { textField in
            textField.placeholder = exerciseNamePlaceholder
            textField.text = exercise.name
        }
        
        alertController.addTextField { textField in
            textField.placeholder = setsPlaceholder
            textField.keyboardType = .numberPad
            textField.text = "\(exercise.sets)"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = repetitionsPlaceholder
            textField.keyboardType = .numberPad
            textField.text = "\(exercise.repetitions)"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = weightPlaceholder
            textField.keyboardType = .decimalPad
            textField.text = "\(exercise.weight)"
        }
        
        let addActionTitle = NSLocalizedString("save_action_title", comment: "")
        let addAction = UIAlertAction(title: addActionTitle, style: .default) { [weak self] _ in
            guard let name = alertController.textFields?[0].text, !name.isEmpty,
                  let setsText = alertController.textFields?[1].text, !setsText.isEmpty,
                  let repetitionsText = alertController.textFields?[2].text, !repetitionsText.isEmpty,
                  let weightText = alertController.textFields?[3].text, !weightText.isEmpty,
                  let sets = Int(setsText), let repetitions = Int(repetitionsText),
                  let weight = Double(weightText)
            else { return }
            
            self?.updateExercise(exercise, with: name, sets: sets, repetitions: repetitions, weight: weight)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action_title", comment: ""), style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    func updateExercise(_ exercise: Exercise, with name: String, sets: Int, repetitions: Int, weight: Double) {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                exercise.name = name
                exercise.sets = sets
                exercise.repetitions = repetitions
                exercise.weight = weight
                tableView.reloadData()
            }
        } catch {
            print("Error updating exercise: \(error)")
        }
    }
    
    func deleteExercise(at indexPath: IndexPath) {
        guard let realm = realm, let exerciseToDelete = exercises?[indexPath.row] else { return }
        
        do {
            try realm.write {
                realm.delete(exerciseToDelete)
                tableView.reloadData()
            }
        } catch {
            print("Error deleting exercise: \(error)")
        }
    }
}

extension ExercisesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {
            fatalError("Failed to dequeue ExerciseTableViewCell")
        }
        
        guard let exercises = exercises, indexPath.row < exercises.count else {
            print("Invalid index or empty exercises list")
            return cell
        }
        
        let exercise = exercises[indexPath.row]
        configureCell(cell, with: exercise)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let exercise = exercises?[indexPath.row] else {
                return
            }
            
        let alertController = UIAlertController(title: NSLocalizedString("exercise_information_title", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("ok_button_title", comment: ""), style: .default, handler: nil))

        let setsText = NSLocalizedString("sets_label", comment: "")
        let repetitionsText = NSLocalizedString("repetitions_label", comment: "")
        let weightText = NSLocalizedString("weight_label", comment: "")

        let exerciseInfo = NSLocalizedString("exercise_info_format", comment: "")
        let formattedMessage = String(format: exerciseInfo, exercise.name, setsText, exercise.sets, repetitionsText, exercise.repetitions, weightText, exercise.weight)

        alertController.message = formattedMessage
            
            present(alertController, animated: true, completion: nil)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
}
