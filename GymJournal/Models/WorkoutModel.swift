import Foundation
import RealmSwift

class Exercise: Object {
    @Persisted(primaryKey: true) var objectId = ObjectId.generate()
    @Persisted var name: String = ""
    @Persisted var sets: Int = 0
    @Persisted var repetitions: Int = 0
    @Persisted var weight: Double = 0.0
}

class Workout: Object {
    @Persisted(primaryKey: true) var objectId = ObjectId.generate()
    @Persisted var name: String = ""
    var exercises = List<Exercise>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    func addExercise(_ exercise: Exercise) {
        guard let realm = realm else { return }

            do {
                if realm.isInWriteTransaction {
                    exercises.append(exercise)
                } else {
                    try realm.write {
                        exercises.append(exercise)
                        realm.add(exercise)
                    }
                }
            } catch {
                print("Ошибка при добавлении упражнения к тренировке: \(error)")
            }
        }
}

