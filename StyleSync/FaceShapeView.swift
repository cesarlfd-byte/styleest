import SwiftUI

struct FaceShapeView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFaceIndex = -1 // -1 = nenhum selecionado
    
    let faceOptions = [
        ("Redondo", "face_round"),
        ("Quadrado", "face_square"),
        ("Coração", "face_heart"),
        ("Diamante", "face_diamond"),
        ("Oblongo", "face_oblong"),
        ("Triângulo", "face_triangle"),
        ("Oval", "face_oval"),
        ("Triângulo invertido", "face_inverted_triangle"),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Formato do rosto")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    
                    
                    Text("Escolha a forma que mais se aproxima do seu rosto.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Chips de formato de rosto
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<faceOptions.count, id: \.self) { i in
                            Button {
                                selectedFaceIndex = i
                                profile.faceShape = faceOptions[i].0
                                profile.faceShapeIcon = faceOptions[i].1
                            } label: {
                                let isSelected = selectedFaceIndex == i
                                let bg = isSelected
                                    ? (colorScheme == .dark ? AppColors.lightPurple.opacity(0.12) : AppColors.lightPurple.opacity(0.18))
                                    : (colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
                                let border = (colorScheme == .dark
                                    ? (isSelected ? AppColors.lightPurple : Color.gray.opacity(0.3))
                                    : (isSelected ? AppColors.darkPurple : Color.gray.opacity(0.3)))
                                let iconColor = isSelected ? (colorScheme == .dark ? AppColors.lightPurple : AppColors.darkPurple) : (colorScheme == .dark ? .white : AppColors.darkPurple)
                                
                                VStack(spacing: 12) {
                                    Image(faceOptions[i].1)
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(iconColor)
                                    
                                    Text(faceOptions[i].0)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .frame(height: 20)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 110)
                                .padding(.vertical, 16)
                                .background(bg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(border, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .navigationTitle("Rosto")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                // Se já existe uma seleção, carregar
                if !profile.faceShape.isEmpty {
                    if let index = faceOptions.firstIndex(where: { $0.0 == profile.faceShape }) {
                        selectedFaceIndex = index
                    }
                }
            }
            
            // Botão fixo e full width (padrão)
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
                        isEnabled: selectedFaceIndex != -1
                    )
                } else {
                    // Modo onboarding: continua para próxima tela
                    PrimaryNavigationButton(
                        destination: BodyTypeView(),
                        label: "Continuar",
                        isEnabled: selectedFaceIndex != -1
                    )
                }
            }
        }
    }
}

#Preview {
    FaceShapeView()
        .environmentObject(UserProfile())
}
