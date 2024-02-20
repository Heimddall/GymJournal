//
//  JournalViewController.swift
//  GymJournal
//
//  Created by Никита Суровцев on 30.11.23.
//

import UIKit
import RealmSwift

class JournalViewController: UIViewController, ExerciseDelegate {
    
    private var workoutViewModel: WorkoutViewModel!
    var realm: Realm!
    @IBOutlet weak var tableView: UITableView!
    var workouts: Results<Workout>!
    var selectedWorkout: Workout?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        realm = DatabaseManager.shared.realm
        workoutViewModel = WorkoutViewModel(realm: realm)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        
        tableView.register(UINib(nibName: "WorkoutCell", bundle: nil), forCellReuseIdentifier: "WorkoutCell")
        
        workouts = realm.objects(Workout.self)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        print(workouts ?? 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(workouts ?? 0)
    }
    
    @IBAction func addWorkoutButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: NSLocalizedString("add_workout_title", comment: ""), message: NSLocalizedString("enter_workout_name_message", comment: ""), preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("workout_name_placeholder", comment: "")
        }
        
        let addAction = UIAlertAction(title: NSLocalizedString("add_button_title", comment: ""), style: .default) { [weak self] _ in
            guard let name = alertController.textFields?.first?.text, !name.isEmpty else { return }

            DispatchQueue.main.async { [weak self] in
                if (self?.workoutViewModel.getAllWorkouts()?.filter("name == %@", name).first) != nil {
                    self?.showDuplicateWorkoutAlert()
                } else {
                    self?.workoutViewModel.addWorkout(name: name)
                    
                    if let newWorkout = self?.workoutViewModel.getAllWorkouts()?.filter("name == %@", name).first {
                        self?.showExercises(for: newWorkout)
                    }
                    
                    self?.reloadWorkouts()
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action_title", comment: ""), style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    
    func showDuplicateWorkoutAlert() {
        let alert = UIAlertController(title: NSLocalizedString("workout_already_exists_title", comment: ""), message: NSLocalizedString("workout_already_exists_message", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadWorkouts() {
        workouts = workoutViewModel.getAllWorkouts()
        tableView.reloadData()
    }
    
    func showExercises(for workout: Workout) {
        let exercisesVC = ExercisesViewController(nibName: "ExercisesViewController", bundle: nil)
            exercisesVC.workout = workout
        exercisesVC.onSaveExercises = { [weak self] exercises in
                self?.didAddExercisesToWorkout(workout, exercises: exercises)
            }
            exercisesVC.exercises = workout.exercises
            exercisesVC.delegate = self
            exercisesVC.realm = realm
            navigationController?.pushViewController(exercisesVC, animated: true)
        
    }
    
    
    func didAddExercisesToWorkout(_ workout: Workout, exercises: List<Exercise>) {
        guard let realm = realm else { return }

            do {
                try realm.write {
                    if let existingWorkout = realm.objects(Workout.self).filter("name == %@", workout.name).first {
                        existingWorkout.exercises.removeAll()
                        existingWorkout.exercises.append(objectsIn: exercises)
                    } else {
                        realm.add(workout)
                        workout.exercises.append(objectsIn: exercises)
                    }
                }
                reloadWorkouts()
            } catch {
                print("Ошибка сохранения тренировки: \(error)")
            }
        saveWorkout(workout)
    }
    
    func saveWorkout(_ workout: Workout) {
        do {
            try realm.write {
                realm.add(workout)
            }
        } catch {
            print("Ошибка сохранения тренировки: \(error)")
        }
    }
    
    
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }

        let point = gestureRecognizer.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showActionsForWorkout(at: indexPath)
        }
    }
    
       func showActionsForWorkout(at indexPath: IndexPath) {
           let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

           let editActionTitle = NSLocalizedString("edit_workout_button_title", comment: "")
           let deleteActionTitle = NSLocalizedString("delete_workout_button_title", comment: "")
           let cancelActionTitle = NSLocalizedString("cancel_action_title", comment: "")

           let editAction = UIAlertAction(title: editActionTitle, style: .default) { [weak self] _ in
               self?.editWorkout(at: indexPath.row)
           }

           let deleteAction = UIAlertAction(title: deleteActionTitle, style: .destructive) { [weak self] _ in
               self?.deleteWorkout(at: indexPath)
           }

           let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel)

           alertController.addAction(editAction)
           alertController.addAction(deleteAction)
           alertController.addAction(cancelAction)

           present(alertController, animated: true)
       }

       func deleteWorkout(at indexPath: IndexPath) {
           guard let realm = realm, indexPath.row < workouts.count else {
               return
           }

           do {
               try realm.write {
                   let workout = workouts[indexPath.row]
                   realm.delete(workout)
                   reloadWorkouts()
               }
           } catch {
               print("Error deleting workout: \(error)")
           }
       }

       func editWorkout(at index: Int) {
           guard let realm = realm, index < workouts.count else {
               return
           }

           let selectedWorkout = workouts[index]

           let alertController = UIAlertController(title: NSLocalizedString("edit_workout_button_title", comment: ""), message: nil, preferredStyle: .alert)
           alertController.addTextField { textField in
               textField.text = selectedWorkout.name
           }

           let saveActionTitle = NSLocalizedString("save_action", comment: "")
           let saveAction = UIAlertAction(title: saveActionTitle, style: .default) { [weak self] _ in
               guard let newName = alertController.textFields?.first?.text, !newName.isEmpty else {
                   // Пустое имя, обработайте по вашему усмотрению
                   return
               }

               do {
                   try realm.write {
                       selectedWorkout.name = newName
                   }
                   self?.reloadWorkouts()
               } catch {
                   print("Ошибка при сохранении тренировки: \(error)")
               }
           }

           let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_action_title", comment: ""), style: .cancel)

           alertController.addAction(saveAction)
           alertController.addAction(cancelAction)

           present(alertController, animated: true)
       }
   }


extension JournalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutCell else {
            return UITableViewCell()
        }
        let workout = workouts[indexPath.row]
        cell.nameLabel.text = workout.name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWorkout = workouts[indexPath.row]
        showExercises(for: selectedWorkout)
    }

}

