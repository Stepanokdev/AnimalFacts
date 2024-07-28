//
//  AnimalFactsApp.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct AnimalFactsApp: App {
    var body: some Scene {
        WindowGroup {
            AnimalCategoriesView(
                store: Store(initialState: AnimalCategoriesFeature.State()) {
                    AnimalCategoriesFeature()
                }
            )
        }
    }
}
