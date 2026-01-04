import SwiftUI

struct PrimaryButton<Content: View>: View {
    let action: () -> Void
    let label: () -> Content
    let isEnabled: Bool
    
    var body: some View {
        Button(action: action) {
            label()
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(.white)
                .background(isEnabled ? AppColors.primaryPurple : Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 20)
        }
        .disabled(!isEnabled)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: -4)
    }
}

// Extensão para usar com NavigationLink (destino de navegação)
struct PrimaryNavigationButton<Destination: View>: View {
    let destination: Destination
    let label: String
    let isEnabled: Bool
    
    var body: some View {
        NavigationLink(destination: destination) {
            Text(label)
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(.white)
                .background(isEnabled ? AppColors.primaryPurple : Color.gray.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 20)
        }
        .disabled(!isEnabled)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: -4)
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        Text("Exemplo")
            .safeAreaInset(edge: .bottom) {
                PrimaryNavigationButton(
                    destination: Text("Próxima tela"),
                    label: "Continuar",
                    isEnabled: true
                )
            }
    }
}
