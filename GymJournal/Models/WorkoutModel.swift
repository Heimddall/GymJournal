import Foundation
import RealmSwift

class Exercise: Object {
    @Persisted(primaryKey: true) var objectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var sets: Int = 0
    @Persisted var repetitions: Int = 0
    @Persisted var weight: Double = 0.0
    @Persisted var workout: Workout?
}

class Workout: Object {
    @Persisted(primaryKey: true) var objectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var exercises = List<Exercise>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    func addExercise(_ exercise: Exercise) {
        do {
            try realm?.write {
                exercises.append(exercise)
                realm?.add(self, update: .modified)
            }
        } catch {
            print("Ошибка при добавлении упражнения к тренировке: \(error)")
        }
    }
}

