//
//  AnimalFact.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation

struct AnimalFact: Identifiable, Equatable, Codable {
    let id: UUID
    let fact: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case fact, image
    }
    
    init(id: UUID = UUID(), fact: String, image: String) {
        self.id = id
        self.fact = fact
        self.image = image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = UUID()
        self.fact = try container.decode(String.self, forKey: .fact)
        self.image = try container.decode(String.self, forKey: .image)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(fact, forKey: .fact)
        try container.encode(image, forKey: .image)
    }
}

extension AnimalFact {
    var wordCount: Int {
        fact.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var hasImage: Bool {
        !image.isEmpty
    }
    
    func contains(_ searchTerm: String) -> Bool {
        fact.lowercased().contains(searchTerm.lowercased())
    }
}
