import SwiftUI

struct FashionTrendsView: View {
    @EnvironmentObject var profile: UserProfile
    @StateObject private var trendsService = FashionTrendsService()
    
    @State private var trends: [FashionTrend] = []
    @State private var isLoading = false
    @State private var selectedCategory: TrendCategory = .all
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Buscando tendências...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Analisando moda global 🌍")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if trends.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 70))
                            .foregroundColor(AppColors.primaryPurple)
                        
                        Text("Tendências da Semana")
                            .font(.title.bold())
                        
                        Text("Descubra as últimas tendências de moda personalizadas para seu estilo!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            Task {
                                await loadTrends()
                            }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Ver Tendências")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 250)
                            .background(AppColors.primaryPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: AppColors.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                } else {
                    // Trends list
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Tendências da Semana")
                                    .font(.title2.bold())
                                
                                Text("Personalizadas para você")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            // Category filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(TrendCategory.allCases, id: \.self) { category in
                                        Button(action: {
                                            selectedCategory = category
                                        }) {
                                            Text(category.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(selectedCategory == category ? .semibold : .regular)
                                                .foregroundColor(selectedCategory == category ? .white : .primary)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedCategory == category ? AppColors.primaryPurple : Color.gray.opacity(0.15))
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Trends cards
                            ForEach(filteredTrends) { trend in
                                TrendCard(trend: trend)
                                    .padding(.horizontal)
                            }
                            
                            // Refresh button
                            Button(action: {
                                Task {
                                    await loadTrends()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Atualizar Tendências")
                                }
                                .font(.headline)
                                .foregroundColor(AppColors.primaryPurple)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primaryPurple.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        .padding(.vertical)
                    }
                }
                
                if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Tendências")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTrends: [FashionTrend] {
        if selectedCategory == .all {
            return trends
        }
        return trends.filter { $0.category.lowercased().contains(selectedCategory.rawValue.lowercased()) }
    }
    
    // MARK: - Functions
    
    private func loadTrends() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedTrends = try await trendsService.generateWeeklyTrends(profile: profile)
            
            await MainActor.run {
                trends = loadedTrends
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erro ao carregar tendências: \(error.localizedDescription)"
                isLoading = false
                // Mesmo com erro, mostrar fallback
                trends = []
            }
        }
    }
}

// MARK: - Trend Card Component

struct TrendCard: View {
    let trend: FashionTrend
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trend.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(trend.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Relevance score
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text("\(trend.relevanceScore)")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.yellow.opacity(0.2))
                .clipShape(Capsule())
            }
            
            // Description
            Text(trend.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isExpanded ? nil : 2)
            
            // Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(trend.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AppColors.primaryPurple.opacity(0.1))
                            .foregroundColor(AppColors.primaryPurple)
                            .clipShape(Capsule())
                    }
                }
            }
            
            // How to wear (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(AppColors.primaryPurple)
                        
                        Text("Como usar:")
                            .font(.subheadline.bold())
                    }
                    
                    Text(trend.howToWear)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(AppColors.primaryPurple.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Expand/Collapse button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Ver menos" : "Como usar")
                        .font(.caption.bold())
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(AppColors.primaryPurple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    FashionTrendsView()
        .environmentObject(UserProfile())
}
