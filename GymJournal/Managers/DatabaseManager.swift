//
//  DatabaseManager.swift
//  GymJournal
//
//  Created by Никита Суровцев on 30.12.23.
//

import Foundation
import RealmSwift

class DatabaseManager {
    static let shared = DatabaseManager()

    var realm: Realm

    private init() {
        do {
            self.realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
}
