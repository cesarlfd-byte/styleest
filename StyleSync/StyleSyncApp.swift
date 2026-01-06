import SwiftUI

@main
struct StyleSyncApp: App {
    @StateObject private var userProfile = UserProfile()
    
    var body: some Scene {
        WindowGroup {
            // Se o usuário já completou o onboarding, mostra a TabBar
            // Senão, mostra o Onboarding
            if userProfile.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(userProfile)
            } else {
                OnboardingView()
                    .environmentObject(userProfile)
            }
        }
    }
}
