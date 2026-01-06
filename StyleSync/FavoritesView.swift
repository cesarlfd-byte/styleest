import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingClearAlert = false
    @State private var selectedTag: String = "Todos"
    
    private var filteredFavorites: [FavoriteLook] {
        favoritesManager.filteredFavorites(by: selectedTag == "Todos" ? nil : selectedTag)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtro de tags
                if !favoritesManager.favorites.isEmpty && favoritesManager.allTags.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(favoritesManager.allTags, id: \.self) { tag in
                                TagFilterButton(
                                    title: tag,
                                    isSelected: selectedTag == tag,
                                    action: {
                                        withAnimation {
                                            selectedTag = tag
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }
                    .background(Color(.systemBackground))
                    
                    Divider()
                }
                
                // Conteúdo
                ZStack {
                    if favoritesManager.favorites.isEmpty {
                        // Estado vazio
                        VStack(spacing: 16) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                            
                            Text("Nenhum look favoritado")
                                .font(.title2.bold())
                            
                            Text("Explore os looks na Home e favorite seus preferidos!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    } else if filteredFavorites.isEmpty {
                        // Sem resultados no filtro
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 64))
                                .foregroundColor(.gray)
                            
                            Text("Nenhum resultado")
                                .font(.title2.bold())
                            
                            Text("Não há looks com a tag '\(selectedTag)'")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    } else {
                        // Lista de favoritos
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(filteredFavorites) { favoriteLook in
                                    // Envolver em NavigationLink se for look gerado por IA
                                    if favoriteLook.look.generatedImage != nil {
                                        NavigationLink(destination: AILookDetailView(look: favoriteLook.look)) {
                                            FavoriteLookCard(
                                                favoriteLook: favoriteLook,
                                                onRemove: {
                                                    withAnimation {
                                                        favoritesManager.removeFavorite(favoriteLook)
                                                    }
                                                },
                                                onShare: {
                                                    shareLook(favoriteLook)
                                                }
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        FavoriteLookCard(
                                            favoriteLook: favoriteLook,
                                            onRemove: {
                                                withAnimation {
                                                    favoritesManager.removeFavorite(favoriteLook)
                                                }
                                            },
                                            onShare: {
                                                shareLook(favoriteLook)
                                            }
                                        )
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !favoritesManager.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Text("Limpar")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Limpar Favoritos", isPresented: $showingClearAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Limpar Tudo", role: .destructive) {
                    withAnimation {
                        favoritesManager.clearAll()
                        selectedTag = "Todos"
                    }
                }
            } message: {
                Text("Tem certeza que deseja remover todos os looks favoritos?")
            }
        }
    }
    
    // Função de compartilhamento
    private func shareLook(_ favoriteLook: FavoriteLook) {
        let text = """
        Olha esse look que eu favoritei! 💜
        
        \(favoriteLook.title)
        \(favoriteLook.description)
        
        Tags: \(favoriteLook.tags.joined(separator: ", "))
        
        #StyleEst #Fashion
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Botão de Filtro de Tag
struct TagFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppColors.primaryPurple : Color.gray.opacity(0.15))
                )
        }
    }
}

// MARK: - Card de Look Favorito
struct FavoriteLookCard: View {
    let favoriteLook: FavoriteLook
    let onRemove: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Imagem (suporta tanto imageName quanto UIImage gerada)
            Group {
                if let imageData = favoriteLook.generatedImageData,
                   let generatedImage = UIImage(data: imageData) {
                    // Imagem gerada por IA
                    Image(uiImage: generatedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if !favoriteLook.imageName.isEmpty {
                    // Tentar carregar imagem do asset
                    if let uiImage = UIImage(named: favoriteLook.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        // Asset não existe, usar gradiente com ícone
                        ZStack {
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [AppColors.lightPurple, AppColors.primaryPurple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.8))
                                Text(favoriteLook.imageName)
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                } else {
                    // Fallback: gradiente
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [AppColors.lightPurple, AppColors.primaryPurple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                // Botões de ação no canto superior direito
                HStack(spacing: 8) {
                    // Botão de compartilhar
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    // NavigationLink para nota
                    NavigationLink(destination: NoteEditorView(favoriteLook: favoriteLook)) {
                        Image(systemName: favoriteLook.note != nil ? "note.text" : "note.text.badge.plus")
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                        
                        // Botão de remover
                        Button(action: onRemove) {
                            Image(systemName: "heart.fill")
                                .font(.body)
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                        }
                    }
                    .padding(12),
                    alignment: .topTrailing
                )
            
            // Conteúdo
            VStack(alignment: .leading, spacing: 8) {
                // Título + ícone
                HStack(spacing: 6) {
                    if favoriteLook.tags.contains("Clima") {
                        Image(systemName: "cloud.sun")
                            .font(.caption)
                            .foregroundColor(.primary)
                    } else if favoriteLook.tags.contains("Música") {
                        Image(systemName: "music.note")
                            .font(.caption)
                            .foregroundColor(.primary)
                    } else {
                        Image(systemName: "person.crop.circle")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Text(favoriteLook.title)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Text(favoriteLook.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Nota do usuário (se existir)
                if let note = favoriteLook.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "quote.opening")
                            .font(.caption2)
                            .foregroundColor(AppColors.primaryPurple)
                        
                        Text(note)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .italic()
                            .lineLimit(3)
                        
                        Image(systemName: "quote.closing")
                            .font(.caption2)
                            .foregroundColor(AppColors.primaryPurple)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.lightPurple.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Tags
                HStack(spacing: 6) {
                    ForEach(favoriteLook.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
                
                // Data de favorito
                Text("Favoritado em \(favoriteLook.favoritedAt, style: .date)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Editor de Notas
struct NoteEditorView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) var dismiss
    let favoriteLook: FavoriteLook
    
    @State private var noteText: String
    
    init(favoriteLook: FavoriteLook) {
        self.favoriteLook = favoriteLook
        _noteText = State(initialValue: favoriteLook.note ?? "")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Preview do look
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            if favoriteLook.tags.contains("Clima") {
                                Image(systemName: "cloud.sun")
                                    .font(.caption)
                            } else if favoriteLook.tags.contains("Música") {
                                Image(systemName: "music.note")
                                    .font(.caption)
                            }
                            
                            Text(favoriteLook.title)
                                .font(.headline)
                        }
                        
                        Text(favoriteLook.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.lightPurple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Campo de texto
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sua nota")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        TextField("Digite suas observações...", text: $noteText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding()
                            .lineLimit(8...15)
                            .frame(minHeight: 150, alignment: .topLeading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("\(noteText.count) caracteres")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Adicionar Nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        favoritesManager.updateNote(for: favoriteLook, note: noteText)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesManager())
}
