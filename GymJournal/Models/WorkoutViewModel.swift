//
//  WorkoutViewModel.swift
//  GymJournal
//
//  Created by Никита Суровцев on 12.01.24.
//

import Foundation
import RealmSwift

class WorkoutViewModel {
    private let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func addWorkout(name: String) {
        let existingWorkout = realm.objects(Workout.self).filter("name == %@", name).first
        guard existingWorkout == nil else {
            return
        }

        let newWorkout = Workout(name: name)
        saveWorkout(newWorkout)
    }

    func saveWorkout(_ workout: Workout) {
        do {
            try realm.write {
                realm.add(workout)
            }
        } catch {
            print("Error saving workout: \(error)")
        }
    }


    func getAllWorkouts() -> Results<Workout>? {
        return realm.objects(Workout.self)
    }
}
