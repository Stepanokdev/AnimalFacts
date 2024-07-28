//
//  AnimalCategory.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation

struct AnimalCategory: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let description: String
    let image: String
    let order: Int
    let status: CategoryStatus
    let content: [AnimalFact]
    
    enum CodingKeys: String, CodingKey {
        case title, description, image, order, status, content
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        image: String,
        order: Int,
        status: CategoryStatus,
        content: [AnimalFact]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.order = order
        self.status = status
        self.content = content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.image = try container.decode(String.self, forKey: .image)
        self.order = try container.decode(Int.self, forKey: .order)
        self.content = try container.decodeIfPresent([AnimalFact].self, forKey: .content) ?? []
        
        if self.content.isEmpty {
            self.status = .comingSoon
        } else {
            self.status = try container.decode(CategoryStatus.self, forKey: .status)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(image, forKey: .image)
        try container.encode(order, forKey: .order)
        try container.encode(status, forKey: .status)
        try container.encode(content, forKey: .content)
    }
}

extension AnimalCategory {
    var isAccessible: Bool {
        status == .free
    }
    
    var factCount: Int {
        content.count
    }
    
    func fact(at index: Int) -> AnimalFact? {
        guard index >= 0 && index < content.count else { return nil }
        return content[index]
    }
}
