import SwiftUI

struct AIRecommendationsView: View {
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    private let aiService = AIRecommendationService()
    
    @State private var aiLooks: [Look] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    // Estado de carregamento
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Criando looks personalizados...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Analisando seu estilo com IA 🤖")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let error = errorMessage {
                    // Estado de erro
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Ops!")
                            .font(.title2.bold())
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            Task {
                                await loadAIRecommendations()
                            }
                        }) {
                            Text("Tentar novamente")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(AppColors.primaryPurple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                } else if aiLooks.isEmpty {
                    // Estado vazio
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primaryPurple)
                        
                        Text("Recomendações com IA")
                            .font(.title2.bold())
                        
                        Text("Gere looks personalizados baseados no seu perfil usando inteligência artificial!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            Task {
                                await loadAIRecommendations()
                            }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Gerar Looks")
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
                    // Lista de recomendações
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Seus looks personalizados")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            Text("Gerado por IA baseado no seu perfil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ForEach(aiLooks) { look in
                                LookCard(look: look)
                                    .padding(.horizontal)
                            }
                            
                            // Botão para gerar novos
                            Button(action: {
                                Task {
                                    await loadAIRecommendations()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Gerar Novos Looks")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primaryPurple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("IA Stylist")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Funções
    private func loadAIRecommendations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let looks = try await aiService.generateMultipleRecommendations(
                profile: profile,
                count: 3
            )
            
            await MainActor.run {
                aiLooks = looks
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

#Preview {
    AIRecommendationsView()
        .environmentObject(UserProfile())
        .environmentObject(FavoritesManager())
}
