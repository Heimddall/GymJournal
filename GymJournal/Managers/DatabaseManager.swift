

import Foundation
import RealmSwift

class DatabaseManager {
    static let shared = DatabaseManager()

    var realm: Realm {
        return try! Realm()
    }
}
