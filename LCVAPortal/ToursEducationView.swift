import SwiftUI

struct ToursEducationView: View {
    @State private var selectedFilter: TourFilter = .guided
    @State private var isGridView = false
    @ObservedObject var userManager: UserManager
    @State private var showingAllFilters = true
    @Namespace private var filterAnimation
    
    enum TourFilter {
        case guided, educational, documents
        
        var title: String {
            switch self {
            case .guided: return "Guided Tours"
            case .educational: return "Workshops"
            case .documents: return "Documents"
            }
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.lcvaBlue, Color.lcvaBlue.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Content
                VStack {
                    // Header with title and buttons
                    HStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 35, height: 35)
                        
                        Text("Tours & Education")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: { /* Search action */ }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            if !showingAllFilters {
                                // Close button
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showingAllFilters = true
                                        selectedFilter = .guided
                                    }
                                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                                    impactLight.impactOccurred()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .padding(.leading)
                                .transition(.opacity.combined(with: .scale))
                                
                                // Selected filter
                                FilterButton(
                                    title: selectedFilter.title,
                                    isSelected: true
                                ) {
                                    // Already selected, do nothing
                                }
                                .matchedGeometryEffect(id: selectedFilter, in: filterAnimation)
                            } else {
                                // Main filter options
                                ForEach([
                                    ("Guided Tours", TourFilter.guided),
                                    ("Workshops", TourFilter.educational),
                                    ("Documents", TourFilter.documents)
                                ], id: \.0) { title, filter in
                                    FilterButton(
                                        title: title,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                            selectedFilter = filter
                                            showingAllFilters = false
                                        }
                                        let impactMedium = UIImpactFeedbackGenerator(style: .medium)
                                        impactMedium.impactOccurred()
                                    }
                                    .matchedGeometryEffect(id: filter, in: filterAnimation)
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingAllFilters)
                    
                    // Content header
                    HStack {
                        Text(selectedFilter.title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isGridView.toggle()
                            }
                        }) {
                            Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    
                    // Content placeholder (to be replaced with actual content)
                    ScrollView {
                        Text("Coming Soon")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    }
                }
            }
        }
    }
} 