//
//  AnimalFactsView.swift
//  AnimalFacts
//
//  Created by  Stepanok Ivan on 28.07.2024.
//

import SwiftUI
import ComposableArchitecture

struct AnimalFactsView: View {
    let store: StoreOf<AnimalFactsFeature>
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    backgroundView
                    
                    VStack(spacing: 0) {
                        FactsCarouselView(
                            facts: viewStore.category.content,
                            currentPage: viewStore.binding(
                                get: \.currentFactIndex,
                                send: AnimalFactsFeature.Action.setCurrentFact
                            ),
                            screenSize: geometry.size
                        )
                        .frame(height: geometry.size.height * 0.85)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle(viewStore.category.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: BackButton {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: ShareButton {
                    viewStore.send(.shareFact)
                }
            )
            .sheet(isPresented: viewStore.binding(
                get: \.isSharePresented,
                send: AnimalFactsFeature.Action.shareSheetDismissed
            )) {
                let content = viewStore.category.content[viewStore.currentFactIndex]
                ShareSheet(activityItems: [content.fact])
            }
        }
    }
    
    private var backgroundView: some View {
        Color("bgColor")
            .edgesIgnoringSafeArea(.all)
    }
}

struct FactsCarouselView: View {
    let facts: [AnimalFact]
    @Binding var currentPage: Int
    let screenSize: CGSize
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(Array(facts.enumerated()), id: \.offset) { index, fact in
                    FactCardView(fact: fact, screenSize: screenSize)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            HStack {
                NavigationButton(type: .previous) {
                    if currentPage > 0 {
                        currentPage -= 1
                    }
                }
                .disabled(currentPage == 0)
                .opacity(currentPage == 0 ? 0 : 1)
                
                Spacer()
                
                NavigationButton(type: .next) {
                    if currentPage < facts.count - 1 {
                        currentPage += 1
                    }
                }
                .disabled(currentPage == facts.count - 1)
                .opacity(currentPage == facts.count - 1 ? 0 : 1)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
    }
}

struct FactCardView: View {
    let fact: AnimalFact
    let screenSize: CGSize
    @Environment(\.colorScheme) var colorScheme
    
    private let horizontalPadding: CGFloat = 20.0
    
    var body: some View {
        VStack(spacing: 16) {
            AsyncImage(url: URL(string: fact.image)) { phase in
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
            .frame(width: screenSize.width - horizontalPadding * 3, height: screenSize.height / 3)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(LocalizedStringKey(fact.fact))
                .font(.system(size: 18))
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
                .padding(.horizontal, horizontalPadding)
                .frame(height: screenSize.height / 4, alignment: .top)
            
            Spacer()
        }
        .padding(10)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(15)
        .shadow(color: Color.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 80)
    }
}

struct NavigationButton: View {
    enum ButtonType {
        case previous, next
        
        var iconName: String {
            switch self {
            case .previous: return "chevron.left"
            case .next: return "chevron.right"
            }
        }
    }
    
    let type: ButtonType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: type.iconName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 50, height: 50)
                .background(Color.primary.opacity(0.1))
                .clipShape(Circle())
        }
        .accessibilityLabel(type == .previous ? "Previous fact" : "Next fact")
    }
}

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .accessibilityLabel("Go back")
    }
}

struct ShareButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
        }
        .accessibilityLabel("Share fact")
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct AnimalFactsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimalFactsView(
            store: Store(
                initialState: AnimalFactsFeature.State(
                    category: AnimalCategory(
                        id: UUID(),
                        title: "Sample Category",
                        description: "Sample description",
                        image: "",
                        order: 1,
                        status: .free,
                        content: [
                            AnimalFact(id: UUID(), fact: "Sample fact", image: "")
                        ]
                    )
                )
            ) {
                AnimalFactsFeature()
            }
        )
    }
}
