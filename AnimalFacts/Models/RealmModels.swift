//
//  RealmModels.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import RealmSwift

class RealmAnimalCategory: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var categoryDescription: String
    @Persisted var image: String
    @Persisted var order: Int
    @Persisted var status: String
    @Persisted var content: List<RealmAnimalFact>
    
    convenience init(from category: AnimalCategory) {
        self.init()
        self.id = category.id.uuidString
        self.title = category.title
        self.categoryDescription = category.description
        self.image = category.image
        self.order = category.order
        self.status = category.status.rawValue
        self.content.append(objectsIn: category.content.map { RealmAnimalFact(from: $0) })
    }
}

class RealmAnimalFact: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var fact: String
    @Persisted var image: String
    
    convenience init(from fact: AnimalFact) {
        self.init()
        self.id = fact.id.uuidString
        self.fact = fact.fact
        self.image = fact.image
    }
}

extension AnimalCategory {
    init(from realmCategory: RealmAnimalCategory) {
        self.id = UUID(uuidString: realmCategory.id) ?? UUID()
        self.title = realmCategory.title
        self.description = realmCategory.categoryDescription
        self.image = realmCategory.image
        self.order = realmCategory.order
        self.status = CategoryStatus(rawValue: realmCategory.status) ?? .comingSoon
        self.content = realmCategory.content.map { AnimalFact(from: $0) }
    }
}

extension AnimalFact {
    init(from realmFact: RealmAnimalFact) {
        self.id = UUID(uuidString: realmFact.id) ?? UUID()
        self.fact = realmFact.fact
        self.image = realmFact.image
    }
}
