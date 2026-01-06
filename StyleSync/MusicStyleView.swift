import SwiftUI

struct MusicGenre: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
}

struct MusicStyleView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGenres: Set<Int> = []
    private let maxSelection = 3
    
    let genres = [
        MusicGenre(name: "Pop", iconName: "music.mic"),
        MusicGenre(name: "Rock", iconName: "guitars"),
        MusicGenre(name: "Hip Hop", iconName: "headphones"),
        MusicGenre(name: "Sertanejo/Country", iconName: "square.stack.3d.up"),
        MusicGenre(name: "Eletrônica", iconName: "bolt"),
        MusicGenre(name: "Jazz", iconName: "music.quarternote.3"),
        MusicGenre(name: "R&B", iconName: "waveform"),
        MusicGenre(name: "Samba", iconName: "music.note"),
        MusicGenre(name: "Regional", iconName: "figure.dance"),
        MusicGenre(name: "Reggae", iconName: "leaf.arrow.triangle.circlepath"),
        MusicGenre(name: "Indie", iconName: "sparkles"),
        MusicGenre(name: "Clássica", iconName: "music.note.list")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Estilo musical")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Escolha até \(maxSelection) gêneros que representam seu estilo.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Grade de gêneros
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(0..<genres.count, id: \.self) { i in
                            Button {
                                if selectedGenres.contains(i) {
                                    selectedGenres.remove(i)
                                } else if selectedGenres.count < maxSelection {
                                    selectedGenres.insert(i)
                                }
                                profile.musicGenres = selectedGenres.map { genres[$0].name }
                            } label: {
                                let isSelected = selectedGenres.contains(i)
                                let bg = isSelected
                                    ? (colorScheme == .dark ? AppColors.lightPurple.opacity(0.12) : AppColors.lightPurple.opacity(0.18))
                                    : (colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
                                let border = (colorScheme == .dark
                                    ? (isSelected ? AppColors.lightPurple : Color.gray.opacity(0.3))
                                    : (isSelected ? AppColors.darkPurple : Color.gray.opacity(0.3)))
                                let iconColor = isSelected ? (colorScheme == .dark ? AppColors.lightPurple : AppColors.darkPurple) : (colorScheme == .dark ? .white : AppColors.darkPurple)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: genres[i].iconName)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(iconColor)
                                    
                                    Text(genres[i].name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(bg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(border, lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Música")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            
            //Botão fixo no rodapé
            .safeAreaInset(edge: .bottom) {
                if profile.isEditingMode {
                    // Modo edição: salva e volta
                    PrimaryButton(
                        action: {
                            dismiss()
                        },
                        label: {
                            Text("Salvar")
                        },
                        isEnabled: !selectedGenres.isEmpty
                    )
                } else {
                    // Modo onboarding: continua para próxima tela
                    PrimaryNavigationButton(
                        destination: WeatherView(),
                        label: "Continuar",
                        isEnabled: !selectedGenres.isEmpty
                    )
                }
            }
        }
        .onAppear {
            // Carregar seleções anteriores se existirem
            selectedGenres = Set()
            for genreName in profile.musicGenres {
                if let index = genres.firstIndex(where: { $0.name == genreName }) {
                    selectedGenres.insert(index)
                }
            }
        }
    }
}

#Preview {
    MusicStyleView()
        .environmentObject(UserProfile())
}
