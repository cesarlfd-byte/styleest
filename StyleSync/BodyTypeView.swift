import SwiftUI

struct BodyTypeView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBodyIndex = -1 // -1 = nenhum selecionado
    
    let bodyOptions = [
        ("Ampulheta", "body_hourglass"),
        ("Retângulo", "body_rectangle"),
        ("Triângulo / Pera", "body_pear"),
        ("Oval / Maçã", "body_apple"),
        ("Triângulo invertido", "body_inverted_triangle"),
        ("Diamante", "body_diamond")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Tipo de corpo")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Escolha a silhueta que mais combina com seu biotipo.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Chips de tipo de corpo
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<bodyOptions.count, id: \.self) { i in
                            Button {
                                selectedBodyIndex = i
                                profile.bodyType = bodyOptions[i].0
                                profile.bodyTypeIcon = bodyOptions[i].1
                            } label: {
                                let isSelected = selectedBodyIndex == i
                                let bg = isSelected
                                    ? (colorScheme == .dark ? AppColors.lightPurple.opacity(0.12) : AppColors.lightPurple.opacity(0.18))
                                    : (colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
                                let border = (colorScheme == .dark
                                    ? (isSelected ? AppColors.lightPurple : Color.gray.opacity(0.3))
                                    : (isSelected ? AppColors.darkPurple : Color.gray.opacity(0.3)))
                                let iconColor = isSelected ? (colorScheme == .dark ? AppColors.lightPurple : AppColors.darkPurple) : (colorScheme == .dark ? .white : AppColors.darkPurple)
                                
                                VStack(spacing: 12) {
                                    Image(bodyOptions[i].1)
                                        .resizable()
                                        .renderingMode(.template)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(iconColor)
                                    
                                    Text(bodyOptions[i].0)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.8)
                                        .frame(height: 32)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
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
                .navigationTitle("Corpo")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                // Carregar seleção anterior se existir
                if !profile.bodyType.isEmpty {
                    if let index = bodyOptions.firstIndex(where: { $0.0 == profile.bodyType }) {
                        selectedBodyIndex = index
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
                        isEnabled: selectedBodyIndex != -1
                    )
                } else {
                    // Modo onboarding: continua para próxima tela
                    PrimaryNavigationButton(
                        destination: HairColorView(),
                        label: "Continuar",
                        isEnabled: selectedBodyIndex != -1
                    )
                }
            }
        }
    }
}

#Preview {
    BodyTypeView()
        .environmentObject(UserProfile())
}

