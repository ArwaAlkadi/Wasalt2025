import SwiftUI

@main
struct WasaltApp: App {

    @StateObject var appState = AppStateViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.showSplash {
                    SplashView()
                } else if appState.showOnboarding {
                    OnboardingView()
                } else {
                    Text("Main App")  // أو HomeView later
                }
            }
        }
    }
}
