//
//  AppDelegate.swift
//  GymJournal
//
//  Created by Никита Суровцев on 26.11.23.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let groupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.GymJournal") {
            let realmFileURL = groupContainerURL.appendingPathComponent("default.realm")
            
            let config = Realm.Configuration(
                fileURL: realmFileURL,
                schemaVersion: 4,
                migrationBlock: { migration, oldSchemaVersion in
                    if oldSchemaVersion < 4 {
                        migration.enumerateObjects(ofType: Exercise.className()) { _, newObject in
                            if let newObject = newObject {
                                if newObject["objectId"] == nil {
                                    newObject["objectId"] = ObjectId.generate()
                                }
                            }
                        }
                        migration.enumerateObjects(ofType: Workout.className()) { _, newObject in
                            if let newObject = newObject {
                                if newObject["objectId"] == nil {
                                    newObject["objectId"] = ObjectId.generate()
                                }
                            }
                        }
                    }
                }
            )
            
            Realm.Configuration.defaultConfiguration = config
            
            do {
                let realm = try Realm()
                print("Realm file URL: \(realm.configuration.fileURL?.absoluteString ?? "N/A")")
                
            } catch let error as NSError {
                fatalError("Failed to initialize Realm: \(error.localizedDescription)")
            }
        }

        return true
    }
        // MARK: UISceneSession Lifecycle
        
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            // Called when a new scene session is being created.
            // Use this method to select a configuration to create the new scene with.
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
        
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
            // Called when the user discards a scene session.
            // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
            // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        }
        
        
    }
    
