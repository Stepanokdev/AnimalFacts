//
//  AnimalCategoriesView.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct AnimalCategoriesView: View {
    let store: StoreOf<AnimalCategoriesFeature>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    backgroundView
                    
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewStore.categories) { category in
                                CategoryRowView(category: category)
                                    .onTapGesture {
                                        viewStore.send(.categoryTapped(category))
                                    }
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel(Text("Category: \(category.title)"))
                                    .accessibilityHint(Text("Tap to view facts about \(category.title)"))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .refreshable {
                        await viewStore.send(.onAppear).finish()
                    }
                }
                .navigationTitle(Text("", comment: "Title for the animal categories screen"))
                
                .navigationDestination(
                    store: self.store.scope(
                        state: \.$destination,
                        action: { .destination($0) }
                    )
                ) { destinationStore in
                    SwitchStore(destinationStore) {
                        switch $0 {
                        case .facts:
                            CaseLet(
                                /AnimalCategoriesFeature.Destination.State.facts,
                                 action: AnimalCategoriesFeature.Destination.Action.facts
                            ) { factStore in
                                AnimalFactsView(store: factStore)
                            }
                        }
                    }
                }
                .overlay {
                    if viewStore.isLoading {
                        LoadingView()
                    }
                }
                .alert(store: self.store.scope(state: \.$alert, action: { .alert($0) }))
            }
            .task {
                await viewStore.send(.onAppear).finish()
            }
            .overlay {
                if let error = viewStore.error, let errorDescription = error.errorDescription {
                    ErrorView(message: errorDescription, retryAction: { viewStore.send(.dismissError) })
                }
            }
        }
    }
    
    private var backgroundView: some View {
        Color("bgColor")
            .edgesIgnoringSafeArea(.all)
    }
}

struct CategoryRowView: View {
    let category: AnimalCategory
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: category.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 120, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(category.title))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(LocalizedStringKey(category.description))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                if category.status == .paid {
                    Label("Premium", systemImage: "lock.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding(12)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.primary.opacity(0.1), radius: 2, x: 0, y: 2)
        .overlay {
            if category.status == .comingSoon {
                ComingSoonOverlay()
            }
        }
    }
}

struct ComingSoonOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .cornerRadius(5)
                .overlay(
                    Image("comingSoon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.trailing, 8),
                    alignment: .trailing
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AnimalCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        AnimalCategoriesView(
            store: Store(initialState: AnimalCategoriesFeature.State()) {
                AnimalCategoriesFeature()
            }
        )
        .preferredColorScheme(.light)
        
        AnimalCategoriesView(
            store: Store(initialState: AnimalCategoriesFeature.State()) {
                AnimalCategoriesFeature()
            }
        )
        .preferredColorScheme(.dark)
    }
}
