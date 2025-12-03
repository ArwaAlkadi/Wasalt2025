
import Foundation
import SwiftUI

// MARK: - 1. Model (Data Structure)

/// Represents a single step/page in the onboarding process.
struct OnboardingStep: Identifiable {
    let id = UUID()
    let iconNameLight: String // The base name for the icon in light mode (e.g., "Train")
    let iconNameDark: String  // The base name for the icon in dark mode (e.g., "Train Dark")
    let title: String         // The main title (Arabic text)
    let description: String   // The detailed description (Arabic text)
    let isLastPage: Bool      // Flag to determine if it should show the final button
}
import Foundation

struct OnboardingPage {
    
    // Icon names (you already have them in Assets)
    let lightIcon: String
    let darkIcon: String

    let title: String
    let subtitle: String
}
