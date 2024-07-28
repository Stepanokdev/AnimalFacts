//
//  AnimalFactsFeature.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import ComposableArchitecture

struct AnimalFactsFeature: Reducer {
    struct State: Equatable {
        let category: AnimalCategory
        var currentFactIndex: Int = 0
        var isSharePresented: Bool = false
        var error: ShareError?
    }
    
    enum Action: Equatable {
        case nextFact
        case previousFact
        case setCurrentFact(Int)
        case shareFact
        case shareSheetDismissed
        case dismissError
    }
    
    enum ShareError: Error, Equatable {
        case failedToShare
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nextFact:
                guard state.currentFactIndex < state.category.content.count - 1 else {
                    return .none
                }
                state.currentFactIndex += 1
                return .none
                
            case .previousFact:
                guard state.currentFactIndex > 0 else {
                    return .none
                }
                state.currentFactIndex -= 1
                return .none
                
            case let .setCurrentFact(index):
                state.currentFactIndex = max(0, min(index, state.category.content.count - 1))
                return .none
                
            case .shareFact:
                state.isSharePresented = true
                return .none
                
            case .shareSheetDismissed:
                state.isSharePresented = false
                return .none
                
            case .dismissError:
                state.error = nil
                return .none
            }
        }
    }
}
