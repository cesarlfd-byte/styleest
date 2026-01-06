import SwiftUI

struct HairColorOption: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

struct HairColorView: View {
    @EnvironmentObject var profile: UserProfile
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedColorIndex = -1
    
    let hairColors = [
        HairColorOption(name: "Preto", color: Color(hex: 0x2D1B10)),
        HairColorOption(name: "Castanho escuro", color: Color(hex: 0x4A352A)),
        HairColorOption(name: "Castanho médio", color: Color(hex: 0x7A5C44)),
        HairColorOption(name: "Castanho claro", color: Color(hex: 0xB58E76)),
        HairColorOption(name: "Loiro escuro", color: Color(hex: 0xC9A86A)),
        HairColorOption(name: "Loiro médio", color: Color(hex: 0xD9B473)),
        HairColorOption(name: "Loiro claro", color: Color(hex: 0xE2A87C)),
        HairColorOption(name: "Loiro platinado", color: Color(hex: 0xF5E6D3)),
        HairColorOption(name: "Ruivo escuro", color: Color(hex: 0xA0522D)),
        HairColorOption(name: "Ruivo médio", color: Color(hex: 0xC1664F)),
        HairColorOption(name: "Ruivo claro", color: Color(hex: 0xE97451)),
        HairColorOption(name: "Grisalho", color: Color(hex: 0xB8B8B8)),
        HairColorOption(name: "Branco", color: Color(hex: 0xF0F0F0)),
        HairColorOption(name: "Rosa", color: Color(hex: 0xFFB6C1)),
        HairColorOption(name: "Azul", color: Color(hex: 0x6495ED)),
        HairColorOption(name: "Roxo", color: Color(hex: 0x9966CC)),
        HairColorOption(name: "Verde", color: Color(hex: 0x90EE90)),
        HairColorOption(name: "Colorido", color: Color(hex: 0xA366C2))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Text("Cor do cabelo")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Escolha a cor que mais combina com seu visual atual.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Chips de cor
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<hairColors.count, id: \.self) { i in
                            Button {
                                selectedColorIndex = i
                                profile.hairColorName = hairColors[i].name
                                profile.hairColor = hairColors[i].color
                            } label: {
                                let isSelected = selectedColorIndex == i
                                let bg = isSelected
                                    ? (colorScheme == .dark ? AppColors.lightPurple.opacity(0.12) : AppColors.lightPurple.opacity(0.18))
                                    : (colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.gray.opacity(0.05))
                                let border = (colorScheme == .dark
                                    ? (isSelected ? AppColors.lightPurple : Color.gray.opacity(0.3))
                                    : (isSelected ? AppColors.darkPurple : Color.gray.opacity(0.3)))
                                
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(hairColors[i].color)
                                        .frame(width: 50, height: 50)
                                    
                                    Text(hairColors[i].name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
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
                .navigationTitle("Cabelo")
                .navigationBarTitleDisplayMode(.inline)
            }
            .scrollIndicators(.hidden)
            .onAppear {
                // Carregar seleção anterior se existir
                if !profile.hairColorName.isEmpty {
                    if let index = hairColors.firstIndex(where: { $0.name == profile.hairColorName }) {
                        selectedColorIndex = index
                    }
                }
            }
            
            // Botão fixo no rodapé
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
                        isEnabled: selectedColorIndex != -1
                    )
                } else {
                    // Modo onboarding: continua para próxima tela
                    PrimaryNavigationButton(
                        destination: MusicStyleView(),
                        label: "Continuar",
                        isEnabled: selectedColorIndex != -1
                    )
                }
            }
        }
    }
}

#Preview {
    HairColorView()
        .environmentObject(UserProfile())
}
