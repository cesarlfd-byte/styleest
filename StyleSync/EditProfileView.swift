import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) var dismiss
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Editar perfil")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Revise ou altere suas preferências para personalizar ainda mais suas sugestões.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Identidade
                    EditableProfileCard(
                        title: "Identidade",
                        value: profile.gender.isEmpty ? "Não definido" : profile.gender,
                        destination: AnyView(
                            GenderSelectionView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Rosto
                    EditableProfileCard(
                        title: "Rosto",
                        value: profile.faceShape.isEmpty ? "Não definido" : profile.faceShape,
                        destination: AnyView(
                            FaceShapeView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Corpo
                    EditableProfileCard(
                        title: "Corpo",
                        value: profile.bodyType.isEmpty ? "Não definido" : profile.bodyType,
                        destination: AnyView(
                            BodyTypeView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Cabelo
                    EditableProfileCard(
                        title: "Cabelo",
                        value: profile.hairColorName.isEmpty ? "Não definido" : profile.hairColorName,
                        destination: AnyView(
                            HairColorView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Música
                    EditableProfileCard(
                        title: "Música",
                        value: profile.musicGenres.isEmpty ? "Não definido" : profile.musicGenres.joined(separator: ", "),
                        destination: AnyView(
                            MusicStyleView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Clima
                    EditableProfileCard(
                        title: "Clima",
                        value: profile.weatherLocation.isEmpty ? "Não definido" : "\(profile.weatherTemperature)° • \(profile.weatherLocation)",
                        destination: AnyView(
                            WeatherView()
                                .onAppear {
                                    profile.isEditingMode = true
                                }
                                .onDisappear {
                                    profile.isEditingMode = false
                                }
                        )
                    )
                    
                    // Botão de resetar perfil
                    VStack(spacing: 16) {
                        Divider()
                            .padding(.vertical, 8)
                        
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.body)
                                Text("Limpar dados do perfil")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Text("Isso irá apagar todos os dados do seu perfil, mas manterá seus looks favoritos.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Configurações")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(false)
                .alert("Refazer onboarding?", isPresented: $showingResetAlert) {
                    Button("Cancelar", role: .cancel) { }
                    Button("Apagar e Recomeçar", role: .destructive) {
                        profile.resetProfile()
                    }
                } message: {
                    Text("Todos os dados do seu perfil serão apagados e você precisará refazer o onboarding. Seus looks favoritos serão mantidos.")
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

// MARK: - EditableProfileCard (genérico com AnyView)
struct EditableProfileCard: View {
    let title: String
    let value: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(UserProfile())
}
