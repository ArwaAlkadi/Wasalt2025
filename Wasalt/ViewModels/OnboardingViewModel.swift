import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {

    // Tracks the current page index
    @Published var currentPage: Int = 0

    // UI will use Environment colorScheme to switch icons/colors automatically
    @Published var isOnboardingFinished: Bool = false

    // Total number of pages
    let pages: [OnboardingPage] = [
        OnboardingPage(
            lightIcon: "Train",
            darkIcon: "Train Dark",
            title: "تنقّل آمن",
            subtitle: "نسهل تنقّلك داخل المترو بخطوات بسيطة!"
        ),
        OnboardingPage(
            lightIcon: "phone",
            darkIcon: "Phone Dark",
            title: "تنبيهات ذكية",
            subtitle: "ننبّهك بالاهتزاز والومض عند الاقتراب من محطتك"
        ),
        OnboardingPage(
            lightIcon: "Map",
            darkIcon: "Map Dark",
            title: "ابدأ رحلتك بثقة",
            subtitle: "اختر وجهتك، واترك التطبيق يتابع خط سير المترو نيابةً عنك"
        )
    ]

    // Go to next page or finish onboarding
    func next() {
        withAnimation(.easeInOut) {   // ← هنا
            if currentPage < pages.count - 1 {
                currentPage += 1         // ← هنا يتحرك الرقم داخل animation
            } else {
                isOnboardingFinished = true
       // عند آخر صفحة، يذهب للصفحة الرئيسية
            }
        }
    }

    func skip() {
        withAnimation(.easeInOut) {  // ← هذا optional لكن يعطي smooth
            isOnboardingFinished = true
        }
    }
}
