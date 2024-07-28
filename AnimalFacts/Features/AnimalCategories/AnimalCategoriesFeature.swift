//
//  AnimalCategoriesFeature.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import Foundation
import ComposableArchitecture
import Combine

struct AnimalCategoriesFeature: Reducer {
    struct State: Equatable {
        var categories: IdentifiedArrayOf<AnimalCategory> = []
        var isLoading = false
        var error: FetchError?
        @PresentationState var alert: AlertState<Action.Alert>?
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case categoriesResponse(TaskResult<[AnimalCategory]>)
        case updateCategories([AnimalCategory])
        case categoryTapped(AnimalCategory)
        case alert(PresentationAction<Alert>)
        case destination(PresentationAction<Destination.Action>)
        case dismissError
        
        enum Alert: Equatable {
            case showAd
            case watchAd
        }
    }
    
    enum FetchError: Error, Equatable, LocalizedError {
        case networkError(String)
        case decodingError
        
        var errorDescription: String? {
            switch self {
            case .networkError(let message):
                return NSLocalizedString("Network error: \(message)", comment: "Network error message")
            case .decodingError:
                return NSLocalizedString("Failed to decode data", comment: "Decoding error message")
            }
        }
    }
    
    @Dependency(\.networkService) var networkService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    await send(.categoriesResponse(TaskResult { try await self.networkService.fetchCategories() }))
                    
                    // Start observing Realm changes
                    for await categories in RealmManager.shared.observeCategories().values {
                        await send(.updateCategories(categories))
                    }
                }
                
            case let .categoriesResponse(.success(categories)):
                state.isLoading = false
                state.error = nil
                return .none
                
            case let .categoriesResponse(.failure(error)):
                state.isLoading = false
                state.error = .networkError(error.localizedDescription)
                return .none
                
            case let .updateCategories(categories):
                state.categories = IdentifiedArray(uniqueElements: categories.sorted(by: { $0.order < $1.order }))
                return .none
                
            case let .categoryTapped(category):
                switch category.status {
                case .free:
                    state.destination = .facts(AnimalFactsFeature.State(category: category))
                case .paid:
                    state.alert = AlertState {
                        TextState("Watch Ad to continue")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("Cancel")
                        }
                        ButtonState(action: .showAd) {
                            TextState("Show Ad")
                        }
                    }
                case .comingSoon:
                    state.alert = AlertState {
                        TextState("Coming Soon")
                    } actions: {
                        ButtonState(role: .cancel) {
                            TextState("OK")
                        }
                    }
                }
                return .none
                
            case .alert(.presented(.showAd)):
                state.isLoading = true
                return .run { send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.alert(.presented(.watchAd)))
                }
                
            case .alert(.presented(.watchAd)):
                state.isLoading = false
                if let category = state.categories.first(where: { $0.status == .paid }) {
                    state.destination = .facts(AnimalFactsFeature.State(category: category))
                }
                return .none
                
            case .dismissError:
                state.error = nil
                return .none
                
            case .alert, .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension AnimalCategoriesFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case facts(AnimalFactsFeature.State)
        }
        
        enum Action: Equatable {
            case facts(AnimalFactsFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.facts, action: /Action.facts) {
                AnimalFactsFeature()
            }
        }
    }
}
