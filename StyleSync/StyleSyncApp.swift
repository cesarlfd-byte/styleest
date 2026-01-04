import SwiftUI

@main
struct StyleSyncApp: App {
    @StateObject private var userProfile = UserProfile()
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environmentObject(userProfile)
        }
    }
}
