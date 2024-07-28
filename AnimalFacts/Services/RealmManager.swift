//
//  RealmManager.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import RealmSwift
import Combine

class RealmManager {
    static let shared = RealmManager()
    private init() {}
    
    private var realm: Realm {
        do {
            return try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    func saveCategories(_ categories: [AnimalCategory]) {
        do {
            try realm.write {
                let realmCategories = categories.map { RealmAnimalCategory(from: $0) }
                realm.add(realmCategories, update: .modified)
            }
        } catch {
            print("Error saving categories to Realm: \(error)")
        }
    }
    
    func getCategories() -> [AnimalCategory] {
        let realmCategories = realm.objects(RealmAnimalCategory.self).sorted(byKeyPath: "order")
        return realmCategories.map { AnimalCategory(from: $0) }
    }
    
    func observeCategories() -> AnyPublisher<[AnimalCategory], Never> {
        let realmCategories = realm.objects(RealmAnimalCategory.self).sorted(byKeyPath: "order")
        return realmCategories.collectionPublisher
            .subscribe(on: DispatchQueue.main)
            .map { $0.map { AnimalCategory(from: $0) } }
            .catch { error -> AnyPublisher<[AnimalCategory], Never> in
                print("Error observing Realm categories: \(error)")
                return Just([]).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func clearAllData() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Error clearing Realm data: \(error)")
        }
    }
}
