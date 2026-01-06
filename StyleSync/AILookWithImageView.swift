import SwiftUI
import UIKit

struct AILookWithImageView: View {
    @EnvironmentObject var profile: UserProfile
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    private let aiService = AIRecommendationServiceSimple()
    
    @State private var completeLook: CompleteLook?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var selectedOccasion = "casual"
    @State private var circleRotation: Double = 0
    @State private var loadingSessionId = UUID() // ID fixo para cada sessão de loading
    
    let occasions = ["casual", "trabalho", "festa", "esporte"]
    
    // DALL-E 3 gera imagens em 1024x1792 (proporção 9:16 vertical)
    private let dalleImageAspectRatio: CGFloat = 1024 / 1792
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if isGenerating {
                        // Estado gerando
                        VStack(spacing: 24) {
                            // Animação de loading
                            ZStack {
                                // Círculo de fundo (não gira)
                                Circle()
                                    .stroke(AppColors.primaryPurple.opacity(0.2), lineWidth: 4)
                                    .frame(width: 100, height: 100)
                                
                                // Círculo animado (gira)
                                Circle()
                                    .trim(from: 0, to: 0.7)
                                    .stroke(AppColors.primaryPurple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                    .rotationEffect(.degrees(circleRotation))
                                
                                // Varinha mágica (não gira - fica fixa)
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.primaryPurple)
                            }
                            .padding(.top, 40)
                            .id(loadingSessionId) // ID fixo para esta sessão de loading
                            .onAppear {
                                // Reiniciar animação do zero
                                circleRotation = 0
                                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                                    circleRotation = 360
                                }
                            }
                            
                            VStack(spacing: 12) {
                                Text("Gerando look com IA...")
                                    .font(.title2.bold())
                                
                                VStack(spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "1.circle.fill")
                                            .foregroundColor(AppColors.primaryPurple)
                                        Text("Criando descrição personalizada")
                                            .font(.subheadline)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "2.circle.fill")
                                            .foregroundColor(AppColors.primaryPurple)
                                        Text("Gerando imagem com DALL-E 3")
                                            .font(.subheadline)
                                    }
                                }
                                .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("⏱️ Isso pode levar 20-40 segundos")
                                    .font(.caption.bold())
                                    .foregroundColor(AppColors.primaryPurple)
                                
                                Text("Estamos usando DALL-E 3 da OpenAI para criar uma imagem profissional de alta qualidade!")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        
                    } else if let complete = completeLook {
                        // Look gerado
                        VStack(alignment: .leading, spacing: 20) {
                            // Imagem gerada pelo DALL-E 3 com título sobreposto
                            ZStack(alignment: .bottom) {
                                Image(uiImage: complete.image)
                                    .resizable()
                                    .aspectRatio(dalleImageAspectRatio, contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                // Overlay gradiente para legibilidade
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .clear,
                                        .black.opacity(0.3),
                                        .black.opacity(0.7)
                                    ]),
                                    startPoint: .center,
                                    endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                
                                // Título e descrição sobrepostos
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(.white)
                                        Text(complete.recommendation.title)
                                            .font(.title2.bold())
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(complete.recommendation.description)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.95))
                                        .lineLimit(2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            }
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)
                            
                            // Informações do look
                            VStack(alignment: .leading, spacing: 12) {
                                // Peças
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Peças do look:")
                                        .font(.headline)
                                    
                                    ForEach(complete.recommendation.items, id: \.self) { item in
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(AppColors.primaryPurple)
                                                .font(.caption)
                                            Text(item)
                                                .font(.subheadline)
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                // Dica de estilo
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Dica de estilo")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(complete.recommendation.styleNote)
                                            .font(.subheadline)
                                    }
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                            
                            // Botões de ação
                            VStack(spacing: 12) {
                                // Favoritar
                                Button(action: {
                                    saveLookToFavorites(complete)
                                }) {
                                    HStack {
                                        Image(systemName: isLookFavorited(complete) ? "heart.fill" : "heart")
                                        Text(isLookFavorited(complete) ? "Favoritado" : "Favoritar Look")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isLookFavorited(complete) ? Color.red : AppColors.primaryPurple)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Compartilhar
                                Button(action: {
                                    shareImage(complete.image, with: complete.recommendation)
                                }) {
                                    HStack {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Compartilhar")
                                    }
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryPurple)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primaryPurple.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Gerar novo
                                Button(action: {
                                    Task {
                                        await generateLook()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Gerar Novo Look")
                                    }
                                    .font(.headline)
                                    .foregroundColor(AppColors.primaryPurple)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primaryPurple.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    } else {
                        // Estado inicial
                        VStack(spacing: 24) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 80))
                                .foregroundColor(AppColors.primaryPurple)
                            
                            Text("Gerar Look com Imagem")
                                .font(.title.bold())
                            
                            Text("A IA vai criar um look personalizado E gerar uma imagem profissional usando DALL-E 3 da OpenAI!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // Seletor de ocasião
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Escolha a ocasião:")
                                    .font(.headline)
                                
                                // Grid adaptável para evitar quebra de texto em telas pequenas
                                LazyVGrid(columns: [
                                    GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 12)
                                ], spacing: 12) {
                                    ForEach(occasions, id: \.self) { occasion in
                                        Button(action: {
                                            selectedOccasion = occasion
                                        }) {
                                            Text(occasion.capitalized)
                                                .font(.subheadline)
                                                .fontWeight(selectedOccasion == occasion ? .semibold : .regular)
                                                .foregroundColor(selectedOccasion == occasion ? .white : .primary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    Capsule()
                                                        .fill(selectedOccasion == occasion ? AppColors.primaryPurple : Color.gray.opacity(0.15))
                                                )
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            Button(action: {
                                Task {
                                    await generateLook()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "wand.and.stars")
                                    Text("Gerar Look + Imagem")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 300)
                                .background(AppColors.primaryPurple)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: AppColors.primaryPurple.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    
                    if let error = errorMessage {
                        // Erro
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
                .padding()
            }
            .navigationTitle("IA com Imagens")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Funções
    private func generateLook() async {
        // Resetar estado para garantir que a animação funcione
        await MainActor.run {
            completeLook = nil
            errorMessage = nil
            circleRotation = 0
            loadingSessionId = UUID() // Novo ID para forçar recriação da view
            isGenerating = true
        }
        
        do {
            let look = try await aiService.generateCompleteLook(
                profile: profile,
                occasion: selectedOccasion
            )
            
            await MainActor.run {
                completeLook = look
                isGenerating = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Erro ao gerar look: \(error.localizedDescription)"
                isGenerating = false
            }
        }
    }
    
    private func saveLookToFavorites(_ completeLook: CompleteLook) {
        // Converter para Look primeiro
        let look = Look(
            title: completeLook.recommendation.title,
            description: completeLook.recommendation.description,
            image: completeLook.image,
            tags: ["IA", "DALL-E 3", completeLook.occasion.capitalized]
        )
        
        // Verificar se já existe nos favoritos comparando por dados da imagem
        let existingIndex = favorites.firstIndex { favLook in
            guard let imageData = favLook.generatedImageData,
                  let lookImageData = completeLook.image.jpegData(compressionQuality: 0.8) else {
                return false
            }
            return imageData == lookImageData
        }
        
        if let index = existingIndex {
            // Se já existe, remover dos favoritos
            favoritesManager.removeFavorite(favorites[index])
        } else {
            // Se não existe, adicionar aos favoritos
            favoritesManager.addFavorite(look)
        }
    }
    
    private func isLookFavorited(_ completeLook: CompleteLook) -> Bool {
        // Comparar os dados da imagem para ver se está favoritado
        guard let lookImageData = completeLook.image.jpegData(compressionQuality: 0.8) else {
            return false
        }
        
        return favorites.contains { favLook in
            guard let imageData = favLook.generatedImageData else {
                return false
            }
            return imageData == lookImageData
        }
    }
    
    // Atalho para acessar os favoritos
    private var favorites: [FavoriteLook] {
        return favoritesManager.favorites
    }
    
    private func shareImage(_ image: UIImage, with recommendation: LookRecommendation) {
        // Criar imagem com texto overlay
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let imageWithText = renderer.image { context in
            // Desenhar imagem
            image.draw(at: .zero)
            
            // Adicionar overlay no bottom
            let overlayRect = CGRect(x: 0, y: image.size.height - 150, width: image.size.width, height: 150)
            UIColor.black.withAlphaComponent(0.7).setFill()
            context.fill(overlayRect)
            
            // Adicionar texto
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let descAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            recommendation.title.draw(in: CGRect(x: 20, y: image.size.height - 130, width: image.size.width - 40, height: 30), withAttributes: titleAttributes)
            recommendation.description.draw(in: CGRect(x: 20, y: image.size.height - 95, width: image.size.width - 40, height: 80), withAttributes: descAttributes)
        }
        
        // Compartilhar
        let activityVC = UIActivityViewController(activityItems: [imageWithText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - View de Detalhes do Look (para abrir dos Favoritos)
struct AILookDetailView: View {
    let look: Look
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) var dismiss
    
    // DALL-E 3 gera imagens em 1024x1792 (proporção 9:16 vertical)
    private let dalleImageAspectRatio: CGFloat = 1024 / 1792
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Imagem com título sobreposto
                if let generatedImage = look.generatedImage {
                    ZStack(alignment: .bottom) {
                        Image(uiImage: generatedImage)
                            .resizable()
                            .aspectRatio(dalleImageAspectRatio, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        // Overlay gradiente para legibilidade
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .black.opacity(0.3),
                                .black.opacity(0.7)
                            ]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        // Título e descrição sobrepostos
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.white)
                                Text(look.title)
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Text(look.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.95))
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
                
                // Tags
                HStack(spacing: 8) {
                    ForEach(look.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.primaryPurple.opacity(0.2))
                            .foregroundColor(AppColors.primaryPurple)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                
                // Botões de ação
                VStack(spacing: 12) {
                    // Remover dos favoritos
                    Button(action: {
                        removeFavorite()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "heart.slash.fill")
                            Text("Remover dos Favoritos")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // Compartilhar
                    if let image = look.generatedImage {
                        Button(action: {
                            shareImage(image)
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Compartilhar")
                            }
                            .font(.headline)
                            .foregroundColor(AppColors.primaryPurple)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primaryPurple.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Look Gerado")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func removeFavorite() {
        if let favToRemove = favoritesManager.favorites.first(where: { $0.id == look.id.uuidString }) {
            favoritesManager.removeFavorite(favToRemove)
        }
    }
    
    private func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    AILookWithImageView()
        .environmentObject(UserProfile())
        .environmentObject(FavoritesManager())
}
