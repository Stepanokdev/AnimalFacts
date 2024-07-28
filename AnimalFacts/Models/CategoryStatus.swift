//
//  CategoryStatus.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import SwiftUI

enum CategoryStatus: String, Codable, Equatable {
    case free
    case paid
    case comingSoon = "coming_soon"
    
    var displayName: String {
        switch self {
        case .free:
            return NSLocalizedString("Free", comment: "Free category status")
        case .paid:
            return NSLocalizedString("Premium", comment: "Paid category status")
        case .comingSoon:
            return NSLocalizedString("Coming Soon", comment: "Coming soon category status")
        }
    }
}
